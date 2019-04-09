def project = [:]
project.config    = 'hmpps-env-configs'
project.network   = 'hmpps-delius-network-terraform'
project.dcore     = 'hmpps-delius-core-terraform'
project.alfresco  = 'hmpps-delius-alfresco-shared-terraform'
project.spg       = 'hmpps-spg-terraform'
//project.ndmis     = 'hmpps-ndmis-terraform' //

def environments = [
  'delius-core-sandpit',
  'delius-core-playpit',
  'delius-core-dev',
  'delius-po-test1',
  'delius-po-test2',
  'delius-training',
  'delius-training-test'
]

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
                terragrunt plan -detailed-exitcode --out ${env_name}.plan" \
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
        choice(
          name: 'environment_name',
          choices: environments,
          description: 'Select environment for creation or updating.'
        )
    }

    stages {

        stage('setup') {
            steps {
                dir( project.config ) {
                  git url: 'git@github.com:ministryofjustice/' + project.config, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }
                dir( project.network ) {
                  git url: 'git@github.com:ministryofjustice/' + project.network, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }
                dir( project.dcore ) {
                  git url: 'git@github.com:ministryofjustice/' + project.dcore, branch: 'master', credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
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
            // stage('Plan Delius shared-monitoring')   { steps { script {plan_submodule(project.config, environment_name, project.network, 'shared-monitoring')}}}
          }
        }
    }

    post {
        always {
            deleteDir()

        }
    }

}
