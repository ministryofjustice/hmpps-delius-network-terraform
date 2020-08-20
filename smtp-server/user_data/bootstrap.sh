#!/usr/bin/env bash

set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
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
SMTP_LOG_GROUP="${smtp_log_group}"
REGION="${region}"
SES_KEY_ID_PARAM="${ses_key_id_param}"
SES_PASSWORD_PARAM="${ses_password_param}"
EOF

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
export SMTP_LOG_GROUP="${smtp_log_group}"
export REGION="${region}"
export SES_KEY_ID_PARAM="${ses_key_id_param}"
export SES_PASSWORD_PARAM="${ses_password_param}"
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
- name: smtp
  src: https://github.com/ministryofjustice/hmpps-smtp-installer
  version: master
EOF

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O users.yml

cat << EOF > ~/vars.yml
remote_user_filename: "${bastion_inventory}"
app_name: $HMPPS_ROLE
env_type: $HMPPS_ENVIRONMENT
region: $REGION
mail_hostnme: $MAIL_HOSTNAME
mail_domain: $MAIL_DOMAIN
mail_network: $MAIL_NETWORK
ses_iam_user: $SES_IAM_USER
ses_key_id_param: $SES_KEY_ID_PARAM
ses_password_param: $SES_PASSWORD_PARAM
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
    - smtp
EOF

ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap.yml
