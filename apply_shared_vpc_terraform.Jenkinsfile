def project = [:]
project.config    = 'hmpps-env-configs'
project.network   = 'hmpps-delius-network-terraform'
project.config_version  = ''
project.network_version   = ''
container_image = "mojdigitalstudio/hmpps-terraform-builder-0-11-14:latest"

// Parameters required for job
// parameters:
//     choice:
//       name: 'environment_name'
//       description: 'Environment name.'
//     string:
//       name: 'CONFIG_BRANCH'
//       description: 'Target Branch for hmpps-env-configs'
//     string:
//       name: 'NETWORK_BRANCH'
//       description: 'Target Branch for hmpps-delius-network-terraform'
//     booleanParam:
//       name: 'confirmation'
//       description: 'Whether to require manual confirmation of terraform plans.'
def get_version(env_name, repo_name, override_version) {
  ssm_param_version = sh (
    script: "aws ssm get-parameters --region eu-west-2 --name \"/versions/vpc-network/repo/${repo_name}/${env_name}\" --query Parameters | jq '.[] | select(.Name | test(\"${env_name}\")) | .Value' --raw-output",
    returnStdout: true
  ).trim()

  echo "ssm_param_version - " + ssm_param_version
  echo "override_version - " + override_version

  if (ssm_param_version!="" && override_version=="master") {
    return ":refs/tags/" + ssm_param_version
  } else {
    return override_version
  }
}

def checkout_version(git_project_dir, git_version) {
  sh """
    #!/usr/env/bin bash
    set +e
    pushd "${git_project_dir}"
    git checkout "${git_version}"
    echo `git symbolic-ref -q --short HEAD || git describe --tags --exact-match`
    popd
  """
}

def debug_env(git_project_dir, git_version) {
  sh """
    #!/usr/env/bin bash
    set +e
    pushd "${git_project_dir}"
    git branch
    git describe --tags
    echo `git symbolic-ref -q --short HEAD || git describe --tags --exact-match`
    popd
  """
}

def prepare_env() {
    sh """
    #!/usr/env/bin bash
    docker pull ${env.container_image}
    """
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
            -v ~/.aws:/home/tools/.aws ${env.container_image} \
            bash -c "\
                source env_configs/${env_name}/${env_name}.properties; \
                cd ${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt plan -detailed-exitcode --out ${env_name}.plan > tf.plan.out; \
                exitcode=\\\"\\\$?\\\"; \
                cat tf.plan.out; \
                if [ \\\"\\\$exitcode\\\" == '1' ]; then exit 1; fi; \
                if [ \\\"\\\$exitcode\\\" == '2' ]; then \
                    parse-terraform-plan -i tf.plan.out | jq '.changedResources[] | (.action != \\\"update\\\") or (.changedAttributes | to_entries | map(.key != \\\"tags.source-hash\\\") | reduce .[] as \\\$item (false; . or \\\$item))' | jq -e -s 'reduce .[] as \\\$item (false; . or \\\$item) == false'; \
                    if [ \\\"\\\$?\\\" == '1' ]; then exitcode=2 ; else exitcode=3; fi; \
                fi; \
                echo \\\"\\\$exitcode\\\" > plan_ret;" \
            || exitcode="\$?"; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/${submodule_name}/plan_ret").trim()
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
        -v ~/.aws:/home/tools/.aws ${env.container_image} \
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
    plancode = plan_submodule(config_dir, env_name, git_project, component)
    if (plancode == "2") {
        if ("${confirmation}" == "true") {
            confirm()
        } else {
            env.Continue = true
        }
        if (env.Continue == "true") {
            apply_submodule(config_dir, env_name, git_project, component)
        }
    }
    else if (plancode == "3") {
        apply_submodule(config_dir, env_name, git_project, component)
        env.Continue = true
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

    parameters {
        string(name: 'CONFIG_BRANCH', description: 'Target Branch for hmpps-env-configs', defaultValue: 'master')
        string(name: 'NETWORK_BRANCH', description: 'Target Branch for hmpps-delius-new-tech-terraform', defaultValue: 'master')
    }

    stages {

        stage('setup') {
            steps {
                script {
                  def starttime = new Date()
                  println ("Started on " + starttime)

                  project.config_version = get_version(environment_name, project.config, env.CONFIG_BRANCH)
                  println("Version from function (project.config_version) -- " + project.config_version)

                  project.network_version  = get_version(environment_name, project.network, env.NETWORK_BRANCH)
                  println("Version from function (project.network_version) -- " + project.network_version)

                  def information = """
                  Started on ${starttime}
                  project.config_version -- ${project.config_version}
                  project.network_version  -- ${project.network_version}
                  """

                  println information
                }

                slackSend(message: "\"Apply\" of \"${project.network_version}\" started on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")

                dir( project.config ) {
                  checkout scm: [$class: 'GitSCM',
                              userRemoteConfigs:
                                [[url: 'git@github.com:ministryofjustice/' + project.config, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a' ]],
                              branches:
                                [[name: project.config_version]]],
                              poll: false
                }
                debug_env(project.config, project.config_version)


                dir( project.network ) {
                  checkout scm: [$class: 'GitSCM',
                              userRemoteConfigs:
                                [[url: 'git@github.com:ministryofjustice/' + project.network, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a' ]],
                              branches:
                                [[name: project.network_version]]],
                              poll: false
                }
                debug_env(project.network, project.network_version)

                prepare_env()
            }
        }

        stage('Delius VPC') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.network, 'vpc')
            }
          }
        }

        stage('Delius Peering Connection') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.network, 'peering-connection')
            }
          }
        }

        stage('Delius Internetgateway') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.network, 'internetgateway')
            }
          }
        }

        stage('Delius Natgateway') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.network, 'natgateway')
            }
          }
        }

        stage('Delius Routes') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.network, 'routes')
            }
          }
        }

        stage('Delius Security Groups') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.network, 'security-groups')
            }
          }
        }

        stage('Persistent eip') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.network, 'persistent-eip')
            }
          }
        }

        stage('S3 - OracleDB Backups') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.network, 's3/oracledb-backups')
            }
          }
        }

        stage('S3 - LDAP Backups') {
          steps {
            script {
              do_terraform(project.config, environment_name, project.network, 's3/ldap-backups')
            }
          }
        }

        // stage('Delius Shared Monitoring') {
        //   steps {
        //     catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
        //       do_terraform(project.config, environment_name, project.network, 'shared-monitoring')
        //     }
        //   }
        // }

        stage('Delius SES') {
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.network, 'ses')
            }
          }
        }

        stage('Delius SMTP-Server') {
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.network, 'smtp-server')
            }
          }
        }

        stage('Delius Lambda-Scheduler') {
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.network, 'lambda-scheduler')
            }
          }
        }

        stage('Delius Shared ECS Cluster') {
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.network, 'ecs-cluster')
            }
          }
        }

        stage('Testing - Chaosmonkey') {
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.network, 'testing/chaosmonkey')
            }
          }
        }
    }

    post {
        always {
            deleteDir()
        }
        success {
            slackSend(message: "\"Apply\" of \"${project.network_version}\" completed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'good')
        }
        failure {
            slackSend(message: "\"Apply\" of \"${project.network_version}\" failed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'danger')
        }
    }

}
