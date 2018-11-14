def project = [:]
project.config    = 'hmpps-env-configs'
project.network   = 'hmpps-delius-network-terraform'
project.dcore     = 'hmpps-delius-core-terraform'
project.alfresco  = 'hmpps-delius-alfresco-shared-terraform'
project.spg       = 'hmpps-spg-terraform'
//project.ndmis     = 'hmpps-ndmis-terraform' //

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

def apply_submodule(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF APPLY for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
        -v `pwd`:/home/tools/data \
        -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
        bash -c "\
            source env_configs/${env_name}/${env_name}.properties; \
            cd ${submodule_name}; \
            terragrunt apply ${env_name}.plan"
        set -e
        """
    }
}

def confirm() {
    try {
        timeout(time: 15, unit: 'MINUTES') {
            env.Continue = input(
                id: 'Proceed1', message: 'Apply plan?', parameters: [
                    [$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Apply Terraform']
                ]
            )
        }
    } catch(err) { // timeout reached or input false
        def user = err.getCauses()[0].getUser()
        env.Continue = false
        if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
            echo "Timeout"
            error("Build failed because confirmation timed out")
        } else {
            echo "Aborted by: [${user}]"
        }
    }
}

def do_terraform(config_dir, env_name, git_project, component) {
    if (plan_submodule(config_dir, env_name, git_project, component) == "2") {
        confirm()
        if (env.Continue == "true") {
            apply_submodule(config_dir, env_name, git_project, component)
        }
    }
    else {
        env.Continue = true
    }
}

def debug_env() {
    sh '''
    #!/usr/env/bin bash
    pwd
    ls -al
    '''
}

pipeline {

    agent { label "jenkins_slave" }

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
        stage('Delius Test VPC') {
          steps {
            script {
              do_terraform(project.config, 'delius-test', project.network, 'vpc')
              do_terraform(project.config, 'delius-test', project.network, 'peering-connection')
              do_terraform(project.config, 'delius-test', project.network, 'internetgateway')
              do_terraform(project.config, 'delius-test', project.network, 'natgateway')
              do_terraform(project.config, 'delius-test', project.network, 'routes')
              do_terraform(project.config, 'delius-test', project.network, 'security-groups')
              do_terraform(project.config, 'delius-test', project.network, 'shared-monitoring')
            }
          }
        }
        // delius-perf
        stage('Delius Perf VPC') {
          steps {
            script {
              do_terraform(project.config, 'delius-perf', project.network, 'vpc')
              do_terraform(project.config, 'delius-perf', project.network, 'peering-connection')
              do_terraform(project.config, 'delius-perf', project.network, 'internetgateway')
              do_terraform(project.config, 'delius-perf', project.network, 'natgateway')
              do_terraform(project.config, 'delius-perf', project.network, 'routes')
              do_terraform(project.config, 'delius-perf', project.network, 'security-groups')
              do_terraform(project.config, 'delius-perf', project.network, 'shared-monitoring')
            }
          }
        }

        // delius-stage
        stage('Delius Stage VPC') {
          steps {
            script {
              do_terraform(project.config, 'delius-stage', project.network, 'vpc')
              do_terraform(project.config, 'delius-stage', project.network, 'peering-connection')
              do_terraform(project.config, 'delius-stage', project.network, 'internetgateway')
              do_terraform(project.config, 'delius-stage', project.network, 'natgateway')
              do_terraform(project.config, 'delius-stage', project.network, 'routes')
              do_terraform(project.config, 'delius-stage', project.network, 'security-groups')
              do_terraform(project.config, 'delius-stage', project.network, 'shared-monitoring')
            }
          }
        }

        // // delius-preprod
        stage('Delius PreProd VPC') {
          steps {
            script {
              sh '''
              #!/usr/env/bin bash
              echo "delius-preprod VPC - placeholder"
              '''
              // do_terraform(project.config, 'delius-preprod', project.network, 'vpc')
              // do_terraform(project.config, 'delius-preprod', project.network, 'peering-connection')
              // do_terraform(project.config, 'delius-preprod', project.network, 'internetgateway')
              // do_terraform(project.config, 'delius-preprod', project.network, 'natgateway')
              // do_terraform(project.config, 'delius-preprod', project.network, 'routes')
              // do_terraform(project.config, 'delius-preprod', project.network, 'security-groups')
              // sh '''
              // #!/usr/env/bin bash
              // echo "delius-preprod VPC Shared Monitoring - placeholder"
              // '''
              // // do_terraform(project.config, 'delius-preprod', project.network, 'shared-monitoring')
            }
          }
        }

        // delius-prod
        stage('Delius Prod VPC') {
          steps {
            script {
              sh '''
              #!/usr/env/bin bash
              echo "delius-prod VPC - placeholder"
              '''
              // do_terraform(project.config, 'delius-prod', project.network, 'vpc')
              // do_terraform(project.config, 'delius-prod', project.network, 'peering-connection')
              // do_terraform(project.config, 'delius-prod', project.network, 'internetgateway')
              // do_terraform(project.config, 'delius-prod', project.network, 'natgateway')
              // do_terraform(project.config, 'delius-prod', project.network, 'routes')
              // do_terraform(project.config, 'delius-prod', project.network, 'security-groups')
              // sh '''
              // #!/usr/env/bin bash
              // echo "delius-prod VPC Shared Monitoring - placeholder"
              // '''
              // // do_terraform(project.config, 'delius-prod', project.network, 'shared-monitoring')
            }
          }
        }
    }

    post {
        always {
            deleteDir()

        }
    }

}
