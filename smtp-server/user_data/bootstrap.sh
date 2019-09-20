#!/usr/bin/env bash

yum install -y python-pip git wget unzip

cat << EOF >> /etc/environment
HMPPS_ROLE=${app_name}
HMPPS_FQDN=${app_name}.${private_domain}
HMPPS_STACKNAME=${env_identifier}
HMPPS_STACK="${short_env_identifier}"
HMPPS_ENVIRONMENT=${environment_name}
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${private_domain}"
MAIL_HOSTNAME="${mail_hostname}"
MAIL_DOMAIN="${mail_domain}"
MAIL_NETWORK="${mail_network}"
SES_IAM_USER="${ses_iam_user}"
INT_ZONE_ID="${private_zone_id}"


EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="${app_name}.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT=${environment_name}
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export MAIL_HOSTNAME="${mail_hostname}"
export MAIL_DOMAIN="${mail_domain}"
export MAIL_NETWORK="${mail_network}"
export SES_IAM_USER="${ses_iam_user}"
export INT_ZONE_ID="${private_zone_id}"

cd ~
pip install ansible

cat << EOF > ~/requirements.yml
- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: rsyslog
  src: https://github.com/ministryofjustice/hmpps-rsyslog-role
- name: elasticbeats
  src: https://github.com/ministryofjustice/hmpps-beats-monitoring
- name: users
  src: singleplatform-eng.users
EOF

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O users.yml

cat << EOF > ~/vars.yml
# For user_update cron
remote_user_filename: "${bastion_inventory}"
EOF

cat << EOF > ~/bootstrap.yml
---
- hosts: localhost
  vars_files:
    - "~/vars.yml"
    - "~/users.yml"
  roles:
    - bootstrap
    - rsyslog
    - users
EOF

ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap.yml



###Install and configure postfix###

#vars
app="postfix"
main_cf_file="/etc/postfix/main.cf"
ses_host="email-smtp.eu-west-1.amazonaws.com"
sasl_passwd_file="/etc/postfix/sasl_passwd"
master_cf_file="/etc/postfix/master.cf"
ses_port="587"
rotate_script="/root/iam_rotate_keys"

#Remove Sendmail
yum remove sendmail -y

#Enable postfix service
systemctl enable $${app} ;

#Install cyrus-sasl-plain
yum install cyrus-sasl-plain -y ;

#Stop postfix
systemctl stop $${app}  ;


#Clean master cf file and restore defaults
> $${main_cf_file} ;
postconf -e  "queue_directory = /var/spool/postfix"                     \
    "command_directory = /usr/sbin"                                     \
    "daemon_directory = /usr/libexec/postfix"                           \
    "data_directory = /var/lib/postfix"                                 \
    "mail_owner = postfix"                                              \
    "unknown_local_recipient_reject_code = 550"                         \
    "alias_maps = hash:/etc/aliases"                                    \
    "alias_database = hash:/etc/aliases"                                \
    "debug_peer_level = 2"                                              \
    "sendmail_path = /usr/sbin/sendmail.postfix"                        \
    "newaliases_path = /usr/bin/newaliases.postfix"                     \
    "mailq_path = /usr/bin/mailq.postfix"                               \
    "setgid_group = postdrop"                                           \
    "html_directory = no"                                               \
    "manpage_directory = /usr/share/man"                                \
    "sample_directory = /usr/share/doc/postfix-2.10.1/samples"          \
    "readme_directory = /usr/share/doc/postfix-2.10.1/README_FILES" ;

echo     'debugger_command =
     PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
     ddd $daemon_directory/$process_name $process_id & sleep 5' >> $${main_cf_file} ;

#start postfix
systemctl start $${app}  ;

#Configure SES opts
postconf -e "relayhost = [$ses_host]:$ses_port" "smtp_sasl_auth_enable = yes"     \
     "smtp_sasl_security_options = noanonymous" "smtp_sasl_password_maps = hash:$sasl_passwd_file" \
   "smtp_use_tls = yes" "smtp_tls_security_level = encrypt" "smtp_tls_note_starttls_offer = yes" ;

#Remove/Comment out -o smtp_fallback_relay= fro master.cf file
grep -q "\-o smtp_fallback_relay=" $${master_cf_file} && sed -e '/\-o smtp_fallback_relay=/s/^#*/#/' -i $${master_cf_file} ;

#Pause to allow az1 to complete first and rotate iam Creds
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | cut -f3 -d"-")
if [[ $AZ != "2a" ]] ; then
    systemctl stop $${app}
    sleep 300
fi

############################################################################
#Configure sasl_passwd vars_file
cat << 'EOF' > /root/iam_rotate_keys
#!/usr/bin/env bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin

#vars
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | cut -f3 -d"-")
SES_IAM_USER=
ses_host="email-smtp.eu-west-1.amazonaws.com"
sasl_passwd_file="/etc/postfix/sasl_passwd"
sasl_passwd_db="/etc/postfix/sasl_passwd.db"
ses_port="587"
iam_rotation_log="/var/log/iam_rotate.log"
region="eu-west-2"


if [[ $AZ == "2a" ]] ; then
    ####Rotate key
    EXISTING_ACCESS_ID=$(aws iam list-access-keys --user-name $SES_IAM_USER --max-items 1 | grep "AccessKeyId" | awk '{print $2}' | sed 's/"//g')
    echo "$(date) : Rotating key" > $iam_rotation_log
    echo "Rotating key"
    #Create new Access key
    TEMP_CREDS_FILE="/root/temp_creds_file"
    aws iam create-access-key --user-name $SES_IAM_USER > $TEMP_CREDS_FILE
    NEW_ACCESS_ID=$(cat $TEMP_CREDS_FILE | grep AccessKeyId | awk '{print $2}' | sed 's/"//g')
    NEW_SECRET_KEY=$(cat $TEMP_CREDS_FILE | grep SecretAccessKey | awk '{print $2}'| sed 's/"//g' | sed 's/,//')
    rm -f $TEMP_CREDS_FILE

    ###Convert IAM SecretAccessKey to SES SMTP Password
    MSG="SendRawEmail"
    VerInBytes="2"
    VerInBytes=$(printf \\$(printf '%03o' "$VerInBytes"))
    SignInBytes=$(echo -n "$MSG"|openssl dgst -sha256 -hmac "$NEW_SECRET_KEY" -binary)
    SignAndVer=""$VerInBytes""$SignInBytes""
    SMTP_PASS=$(echo -n "$SignAndVer"|base64)

    #Configure Postifix to use new creds
    #Configure sasl_passwd vars_file
    echo "[$ses_host]:$ses_port $NEW_ACCESS_ID:$SMTP_PASS" > $sasl_passwd_file
    postmap hash:$sasl_passwd_file ;
    chown root:root $sasl_passwd_file $sasl_passwd_db
    chmod 0600      $sasl_passwd_file $sasl_passwd_db
    systemctl restart postfix

    #Remove Old Creds
    aws iam  delete-access-key --access-key-id $EXISTING_ACCESS_ID --user-name $SES_IAM_USER > /dev/null 2>&1 ;

    ###Update Param store
    aws ssm put-parameter --name $SES_IAM_USER-access-key-id          \
                          --description $SES_IAM_USER-access-key-id   \
                          --value $NEW_ACCESS_ID --type "SecureString" --overwrite    \
                          --region $region  > /dev/null 2>&1

    aws ssm put-parameter --name $SES_IAM_USER-ses-password          \
                          --description $SES_IAM_USER-ses-password   \
                          --value $SMTP_PASS    --type "SecureString" --overwrite    \
                          --region $region  > /dev/null 2>&1
else
    #Configure Postifix to use existing creds
    #Configure sasl_passwd vars_file
    CURRENT_SMTP_USER=$(aws ssm get-parameters --with-decryption --names $SES_IAM_USER-access-key-id --region $region --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
    CURRENT_SMTP_PASS=$(aws ssm get-parameters --with-decryption --names $SES_IAM_USER-ses-password  --region $region --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')

    echo "[$ses_host]:$ses_port $CURRENT_SMTP_USER:$CURRENT_SMTP_PASS" > $sasl_passwd_file
    postmap hash:$sasl_passwd_file ;
    chown root:root $sasl_passwd_file $sasl_passwd_db
    chmod 0600      $sasl_passwd_file $sasl_passwd_db
    systemctl restart postfix
fi

EOF

############################################################################

grep -q "SES_IAM_USER=$SES_IAM_USER" $${rotate_script} || sed -i "s/SES_IAM_USER=/SES_IAM_USER=$SES_IAM_USER/" $${rotate_script}
chmod +x $${rotate_script}
$${rotate_script}
#Cert
postconf -e 'smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt' ;

#Configure relay opts
postconf -e "myhostname = $MAIL_HOSTNAME" \
            "mydomain = $MAIL_DOMAIN"     \
            "mynetworks = $MAIL_NETWORK"  ;

postconf -e 'myorigin = $mydomain' \
  'inet_interfaces = all'          \
  'inet_protocols = all'           \
  'local_recipient_maps ='         \
  'relay_domains = $mydestination' \
  'mydestination = $mydomain' ;

#Restart postfix service
systemctl restart $${app}

#Create cron job to rotate access AccessKeys
temp_cron_file="/tmp/temp_cron_file" ;
crontab -l > $temp_cron_file ;
grep -q "@hourly update_users > /dev/null 2>&1" $temp_cron_file  ||  sed -i "s/update_users/update_users > \/dev\/null 2\>\&1/" $temp_cron_file ;
if [[ $AZ == "2a" ]] ; then
    grep -q "$rotate_script" $temp_cron_file || echo "00 21 * * 0 /usr/bin/sh $rotate_script > /dev/null 2>&1" >> $temp_cron_file && crontab $temp_cron_file
else
    grep -q "$rotate_script" $temp_cron_file || echo "05 21 * * 0 /usr/bin/sh $rotate_script > /dev/null 2>&1" >> $temp_cron_file && crontab $temp_cron_file
fi;
rm -f $temp_cron_file ;
