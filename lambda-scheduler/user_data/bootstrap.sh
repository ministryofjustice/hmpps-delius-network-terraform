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
HMPPS_REGION="${region}"
EOF

export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="${app_name}.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT=${environment_name}
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export HMPPS_REGION="${region}"

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

cat << EOF > /root/.started.sh
#!/usr/bin/env bash
date=$(date)
aws lambda invoke --function-name arn:aws:lambda:$HMPPS_REGION:$HMPPS_ACCOUNT_ID:function:$HMPPS_ENVIRONMENT-auto-stop-notification --payload '{ "action": "start" }' start.response.json --invocation-type Event --region $HMPPS_REGION > /var/log/started.sh.log 2>&1
exit_code=$?
echo "$date Invoked function and got exit code $exit_code" >> /var/log/started.sh.log
EOF

cat << EOF > /root/.stopped.sh
#!/usr/bin/env bash
date=$(date)
aws lambda invoke --function-name arn:aws:lambda:$HMPPS_REGION:$HMPPS_ACCOUNT_ID:function:$HMPPS_ENVIRONMENT-auto-stop-notification --payload '{ "action": "stop" }' stop.response.json --invocation-type Event  --region $HMPPS_REGION  > /var/log/stopped.sh.log 2>&1
exit_code=$?
echo "$date Invoked function and got exit code $exit_code" >> /var/log/stopped.sh.log
EOF

chmod +x /root/.st*.sh

cat << EOF > /usr/lib/systemd/system/notifystart.service
[Unit]
Description=Notify Environment Start
After=network.target

[Service]
Type=simple
ExecStart=/root/.started.sh
TimeoutStartSec=0

[Install]
WantedBy=default.target
EOF

cat << EOF > /usr/lib/systemd/system/notifystop.service
[Unit]
Description=Notify Environment Stop
Requires=network.target
DefaultDependencies=no
Before=shutdown.target reboot.target
After=network.target

[Service]
User=root
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/true
ExecStop=/root/.stopped.sh

[Install]
WantedBy=multi-user.target
EOF

touch /var/log/stopped.sh.log  /var/log/started.sh.log
systemctl daemon-reload
systemctl enable notifystop.service
systemctl enable notifystart.service
systemctl start notifystop.service
