def project = [:]
project.config    = 'hmpps-env-configs'
project.network   = 'hmpps-delius-network-terraform'

def prepare_env() {
    sh '''
    #!/usr/env/bin bash
    docker pull mojdigitalstudio/hmpps-terraform-builder:latest
    '''
}

def plan_submodule(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF PLAN for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
            -v `pwd`:/home/tools/data \
            -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
            bash -c "\
                source env_configs/${env_name}/${env_name}.properties; \
                cd ${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt plan > tf.plan.out; \
                exitcode=\\\"\\\$?\\\"; \
                cat tf.plan.out; \
                if [ \\\"\\\$exitcode\\\" == '1' ]; then exit 1; fi; \
                parse-terraform-plan -i tf.plan.out | jq '.changedResources[] | (.action != \\\"update\\\") or (.changedAttributes | to_entries | map(.key != \\\"tags.source-hash\\\") | reduce .[] as \\\$item (false; . or \\\$item))' | jq -e -s 'reduce .[] as \\\$item (false; . or \\\$item) == false'" \
            || exitcode="\$?"; \
            echo "\$exitcode" > plan_ret; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/plan_ret").trim()
    }
}

pipeline {

    agent { label "jenkins_slave" }

    parameters {
        string(name: 'CONFIG_BRANCH', description: 'Target Branch for hmpps-env-configs', defaultValue: 'master')
        string(name: 'NETWORK_BRANCH', description: 'Target Branch for hmpps-delius-new-tech-terraform', defaultValue: 'master')
    }

    stages {

        stage('setup') {
            steps {
                dir( project.config ) {
                  git url: 'git@github.com:ministryofjustice/' + project.config, branch: env.CONFIG_BRANCH, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }
                dir( project.network ) {
                  git url: 'git@github.com:ministryofjustice/' + project.network, branch: env.NETWORK_BRANCH, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }

                prepare_env()
            }
        }
        // delius-test
        stage('Delius VPC') {
          parallel {
            stage('Plan Delius vpc')                 { steps { script {plan_submodule(project.config, environment_name, project.network, 'vpc')}}}
            stage('Plan Delius peering-connection')  { steps { script {plan_submodule(project.config, environment_name, project.network, 'peering-connection')}}}
            stage('Plan Delius internetgateway')     { steps { script {plan_submodule(project.config, environment_name, project.network, 'internetgateway')}}}
            stage('Plan Delius natgateway')          { steps { script {plan_submodule(project.config, environment_name, project.network, 'natgateway')}}}
            stage('Plan Delius routes')              { steps { script {plan_submodule(project.config, environment_name, project.network, 'routes')}}}
            stage('Plan Delius security-groups')     { steps { script {plan_submodule(project.config, environment_name, project.network, 'security-groups')}}}
            stage('Plan Persistent EIP')             { steps { script {plan_submodule(project.config, environment_name, project.network, 'persistent-eip')}}}
            stage('Plan S3 OracleDB Backups')        { steps { script {plan_submodule(project.config, environment_name, project.network, 's3/oracledb-backups')}}}
            stage('Plan S3 LDAP Backups')            { steps { script {plan_submodule(project.config, environment_name, project.network, 's3/ldap-backups')}}}
            stage('Plan Delius shared-monitoring')   { steps { script {plan_submodule(project.config, environment_name, project.network, 'shared-monitoring')}}}
            stage('Plan Delius SES')                 { steps { script {plan_submodule(project.config, environment_name, project.network, 'ses')}}}
            stage('Plan Delius SMTP-Server')         { steps { script {plan_submodule(project.config, environment_name, project.network, 'smtp-server')}}}
            stage('Plan Delius Lambda-Scheduler')    { steps { script {plan_submodule(project.config, environment_name, project.network, 'lambda-scheduler')}}}
            stage('Plan Delius Shared ECS Cluster')  { steps { script {plan_submodule(project.config, environment_name, project.network, 'ecs-cluster')}}}
          }
        }
    }

    post {
        always {
            deleteDir()

        }
    }

}
