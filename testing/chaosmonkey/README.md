# Shared Infrastructure to support automated chaos engineering tools

HMPPS will use the Netflix Chaosmonkey tool in all environments to test and validate automated failure handling of each component that makes up the nDelius service. Initially the testing will focus simply on random termination of EC2 instances belong to specifically tagged ASGs.

The code contained herein manages the following components required to run the Chaosmonkey tool:

- Security Group
    - Dedicated SG with no Ingress, only Egress for comms with AWS API and Docker registry
- AWS Batch Compute Environment & Job Queue
    - Dedicated ECS cluster running in the VPC private subnets
    - Associated ASG will only scale out when tests are running to reduce costs
- Chaosmonkey Batch job definition
- IAM Roles and Policies
    - Batch Service Role
    - Chaosmonkey Job Role
- Jenkinsfile to manage job submissions for each environment
    - Jenkinsfile is managed in [https://github.com/ministryofjustice/ndelius-test-automation](https://github.com/ministryofjustice/ndelius-test-automation)
