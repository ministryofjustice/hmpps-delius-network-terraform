#!/bin/bash
yum install -y amazon-efs-utils
yum install -y nfs-utils
#open file descriptor for stderr
exec 2>>/var/log/ecs/ecs-agent-install.log
set -x
#verify that the agent is running
until curl -s http://localhost:51678/v1/metadata
do
sleep 1
done
#install the Docker volume plugin
docker plugin install rexray/efs REXRAY_PREEMPT=true EFS_REGION=${aws_region} EFS_SECURITYGROUPS=${efs_sg} --grant-all-permissions
#restart the ECS agent
stop ecs 
start ecs