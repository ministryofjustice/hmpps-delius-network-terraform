#!/usr/bin/env bash

yum install -y python-pip git wget

cat << EOF >> /etc/environment
HMPPS_ROLE=${app_name}
HMPPS_FQDN=${app_name}-node${instance_identifier}.${private_domain}
HMPPS_STACKNAME=${env_identifier}
HMPPS_STACK="${short_env_identifier}"
HMPPS_ENVIRONMENT=${route53_sub_domain}
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${private_domain}"
EOF

## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="${app_name}-node${instance_identifier}.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT=${route53_sub_domain}
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"

cd ~
pip install ansible

cat << EOF > ~/requirements.yml
- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: rsyslog
  src: https://github.com/ministryofjustice/hmpps-rsyslog-role
- name: users
  src: singleplatform-eng.users
EOF

cat << EOF > ~/bootstrap_vars.yml
mount_point: "${es_home}"
device_name: "${ebs_device}"
efs_mount_dir: "${efs_mount_dir}"
efs_file_system_id: "${efs_file_system_id}"
region: "${region}"
EOF

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O users.yml

cat << EOF > ~/bootstrap.yml
---

- hosts: localhost
  vars_files:
    - "{{ playbook_dir }}/bootstrap_vars.yml"
    - "{{ playbook_dir }}/users.yml"
  roles:
    - users
    - bootstrap
  tasks:
    - name: Create the elasticsearch group
      group:
        name: elasticsearch
        gid: 3999
        state: present
    - name: Add an elasticsearch user
      user:
        name: elasticsearch
        groups:
          - elasticsearch
          - docker
        uid: 101
        system: true
        state: present
EOF


ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap.yml -vvv


#Create docker-compose file and env file
mkdir -p ${es_home}/service-elasticsearch ${es_home}/elasticsearch/data ${es_home}/elasticsearch/conf.d /opt/curator


if [ "x${efs_mount_dir}" == "x" ];then

cat << EOF > ${es_home}/service-elasticsearch/docker-compose.yml
version: "3"

services:
  elasticsearch:
    image: ${registry_url}/${image_name}:${version} # This is our es 2.3 image
    #image: ${registry_url}/elasticsearch-5:latest # This is our es 5.6 image
    #image: ${registry_url}/elasticsearch:latest # This is our es 6.2 image
    volumes:
      - ${es_home}/elasticsearch/data:/usr/share/elasticsearch/data
      - ${es_home}/elasticsearch/conf.d:/usr/share/elasticsearch/conf.d
      - /opt/curator:/opt/curator
    environment:
      - HMPPS_ES_CLUSTER_NAME=${aws_cluster}
      - HMPPS_ES_NODE_NAME=${app_name}-node${instance_identifier}
      - HMPPS_ES_MIN_MASTER_NODES=2
      - HMPPS_ES_CLUSTER_NODES_01=${app_name}-node1.${private_domain}
      - HMPPS_ES_CLUSTER_NODES_02=${app_name}-node2.${private_domain}
      - HMPPS_ES_CLUSTER_NODES_03=${app_name}-node3.${private_domain}
      - HMPPS_ES_CLUSTER_NODES_04=elasticsearch
      - HMPPS_ES_GATEWAY_EXPECTED_NODES=3
      - HMPPS_ES_GATEWAY_RECOVER_AFTER_TIME=5m
      - HMPPS_ES_GATEWAY_RECOVER_AFTER_NODES=2
      - HMPPS_ES_NETWORK_PUBLISH_HOST=`curl http://169.254.169.254/latest/meta-data/local-ipv4/`
    ports:
      - 9300:9300
      - 9200:9200
    ulimits:
      nofile: 65536

EOF
else
cat << EOF > ${es_home}/service-elasticsearch/docker-compose.yml
version: "3"

services:
  elasticsearch:
    image: ${registry_url}/${image_name}:${version} # This is our es 2.3 image
    #image: ${registry_url}/elasticsearch-5:latest # This is our es 5.6 image
    #image: ${registry_url}/elasticsearch:latest # This is our es 6.2 image
    volumes:
      - ${es_home}/elasticsearch/data:/usr/share/elasticsearch/data
      - ${es_home}/elasticsearch/conf.d:/usr/share/elasticsearch/conf.d
      - ${efs_mount_dir}:${efs_mount_dir}
      - /opt/curator:/opt/curator
    environment:
      - HMPPS_ES_CLUSTER_NAME=${aws_cluster}
      - HMPPS_ES_NODE_NAME=${app_name}-node${instance_identifier}
      - HMPPS_ES_MIN_MASTER_NODES=2
      - HMPPS_ES_CLUSTER_NODES_01=${app_name}-node1.${private_domain}
      - HMPPS_ES_CLUSTER_NODES_02=${app_name}-node2.${private_domain}
      - HMPPS_ES_CLUSTER_NODES_03=${app_name}-node3.${private_domain}
      - HMPPS_ES_CLUSTER_NODES_04=elasticsearch
      - HMPPS_ES_GATEWAY_EXPECTED_NODES=3
      - HMPPS_ES_GATEWAY_RECOVER_AFTER_TIME=5m
      - HMPPS_ES_GATEWAY_RECOVER_AFTER_NODES=2
      - HMPPS_ES_NETWORK_PUBLISH_HOST=`curl http://169.254.169.254/latest/meta-data/local-ipv4/`
      - HMPPS_ES_PATH_REPO=${efs_mount_dir}
    ports:
      - 9300:9300
      - 9200:9200
    ulimits:
      nofile: 65536
EOF

chown -R `id -u elasticsearch`:`id -g elasticsearch` ${efs_mount_dir}
chmod -R 775 ${efs_mount_dir}
fi



chown -R `id -u hmpps_sys_user`:`id -g hmpps_sys_user` ${es_home}/elasticsearch
chmod -R 777 ${es_home}/elasticsearch
ulimit -n 65536
sysctl -w vm.max_map_count=262144
service docker restart
sleep 10
docker-compose -f ${es_home}/service-elasticsearch/docker-compose.yml up -d

# Pull our extra images down to simplify things
docker pull ${registry_url}/hmpps-elasticsearch-5
docker pull ${registry_url}/hmpps-elasticsearch

if [ "x${efs_mount_dir}" != "x" ];then
# See
# http://www.madhur.co.in/blog/2017/04/09/usingcuratordeleteelasticindex.html
# https://adnanahmed.info/blog/2017/11/15/backing_up_and_restoring_es_indices_using_curator/
#Create our curator templates
cat << EOF > /opt/curator/backup.yml
---

actions:
  1:
    action: snapshot
    description: "Create snapshot of ${aws_cluster}"
    options:
      repository: "${aws_cluster}-backup"
      continue_if_exception: False
      wait_for_completion: True
    filters:
      - filtertype: pattern
        kind: regex
        value: ".*$"

EOF

cat << EOF > /opt/curator/restore.yml
---

actions:
  1:
    action: close
    description: "Close indices before restoring snapshot"
    options:
      continue_if_exception: True
      ignore_empty_list: True
    filters:
      - filtertype: pattern
        kind: regex
        value: ".*$"
  2:
    action: restore
    description: "Restore all indices in the most recent snapshot with state SUCCESS"
    options:
      repository: "${aws_cluster}-backup"
      name:
      indices:
      wait_for_completion: True
    filters:
      - filtertype: state
        state: SUCCESS
  3:
    action: open
    description: "Open indices after restoring snapshot"
    filters:
      - filtertype: pattern
        kind: regex
        value: ".*$"

EOF

#Wait for elasticsearch to come up
sleep 60
sudo docker exec service-elasticsearch_elasticsearch_1 bash -c "es_repo_mgr --config /usr/share/elasticsearch/.curator/curator.yml create fs --repository ${aws_cluster}-backup --location ${efs_mount_dir} --compression true"
fi