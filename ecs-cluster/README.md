# Shared ECS Cluster
Given the growing number of ECS based tasks that are needed, a central, shared cluster makes more economical sense.
Particularly as tasks can now run in deidcated security groups and with a dedicated IAM identity, both separate from those of the underlying EC2 host

The EC2 hosts will be provisioned from the latest ECS optimised AMI running AWS Linux 2.
Plugins can be installed at boot time to enable features such as EFS docker volumes for providing shared storage either between
tasks, or to enable multi az failover of tasks.