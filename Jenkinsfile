def project = [
        config         : 'hmpps-env-configs',
        config_version : '',
        network        : 'hmpps-delius-network-terraform',
        network_version: ''
]

def get_version(String repo_name, String override_version) {
  def ssm_param_version = sh(script: "aws ssm get-parameter --name /versions/vpc-network/repo/${repo_name}/${env.ENVIRONMENT} --query Parameter.Value --region eu-west-2 --output text || true", returnStdout: true).trim()
  if (ssm_param_version != "" && override_version == "master") {
    return "refs/tags/${ssm_param_version}"
  } else {
    return override_version
  }
}

def confirm(String component) {
  if (!params.confirmation) return true;
  def changes = sh(script: "grep 'Plan:' '${component}/${env.ENVIRONMENT}.plan.log' | sed -E 's/^.{18}(.+).{4}/\1/'", returnStdout: true).trim()
  try {
    timeout(time: 15, unit: 'MINUTES') {
      return input(message: "Apply changes to ${component}?", parameters: [[$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: changes]])
    }
  } catch (err) { // timeout reached or input false
    String user = err.getCauses()[0].getUser()
    if ('SYSTEM' == user) error("Confirmation timed out") else echo "Aborted by [${user}]"
    return false;
  }
}

void do_terraform(String repo, String component) {
  dir(repo) {
    def plan_status = sh(script: "COMPONENT=${component} ./run.sh plan", returnStatus: true)
    // 0 = No changes, 1 = Error, 2 = Changes
    if (plan_status == 1) error("Error generating plan for ${component}")
    if (plan_status == 0 || (plan_status == 2 && confirm(component))) {
      def apply_status = sh(script: "COMPONENT=${component} ./run.sh apply", returnStatus: true)
      if (apply_status != 0) error("Error applying changes to ${component}")
    }
  }
}

pipeline {
  agent { label "jenkins_agent" }
  options { ansiColor('xterm') }

  parameters {
    string(name: 'CONFIG_BRANCH', description: 'Target Branch for hmpps-env-configs', defaultValue: 'master')
    string(name: 'NETWORK_BRANCH', description: 'Target Branch for hmpps-delius-network-terraform', defaultValue: 'master')
    booleanParam(name: 'confirmation', description: 'Confirm Terraform changes?', defaultValue: true)
  }

  environment {
    CONTAINER = 'mojdigitalstudio/hmpps-terraform-builder-0-12'
    ENVIRONMENT = sh(script: 'basename $(dirname $(dirname $(pwd)))', returnStdout: true).trim()
  }

  stages {
    stage('setup') {
      steps {
        slackSend(message: "\"Apply\" of \"${project.network_version}\" started on \"${env.ENVIRONMENT}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080', '')}|Open>)")

        script {
          project.config_version = get_version(project.config, params.CONFIG_BRANCH)
          project.network_version = get_version(project.network, params.NETWORK_BRANCH)
          println project
        }

        dir(project.config) { checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[url: 'git@github.com:ministryofjustice/' + project.config, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a']], branches: [[name: project.config_version]]], poll: false }
        dir(project.network) { checkout scm: [$class: 'GitSCM', userRemoteConfigs: [[url: 'git@github.com:ministryofjustice/' + project.network, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a']], branches: [[name: project.network_version]]], poll: false }

        sh('docker pull "${CONTAINER}"')
      }
    }

    stage('Core Resources') {
      parallel {
        stage('VPC') { steps { do_terraform(project.network, 'vpc') } }
        stage('Routes') { steps { do_terraform(project.network, 'routes') } }
        stage('Persistent EIP') { steps { do_terraform(project.network, 'persistent-eip') } }
        stage('DB Backups Bucket') { steps { do_terraform(project.network, 's3/oracledb-backups') } }
        stage('LDAP Backups Bucket') { steps { do_terraform(project.network, 's3/ldap-backups') } }
      }
    }

    stage('Primary Resources') {
      parallel {
        stage('NAT Gateway') { steps { do_terraform(project.network, 'natgateway') } }
        stage('ChaosMonkey') { steps { do_terraform(project.network, 'testing/chaosmonkey') } }
        stage('Security Groups') { steps { do_terraform(project.network, 'security-groups') } }
        stage('Internet Gateway') { steps { do_terraform(project.network, 'internetgateway') } }
        stage('Peering Connections') { steps { do_terraform(project.network, 'peering-connection') } }
        stage('SES') { steps { do_terraform(project.network, "ses") } }
      }
    }

    stage('Secondary Resources') {
      parallel {
        stage('SMTP') { steps { do_terraform(project.network, 'smtp-server') } }
        stage('ECS Cluster') { steps { do_terraform(project.network, 'ecs-cluster') } }
        stage('Lambda Scheduler') { steps { do_terraform(project.network, 'lambda-scheduler') } }
      }
    }

    // TODO Shared Monitoring is to be destroyed manually in all environments. Remove once completed.
    // stage('Shared Monitoring') { steps { do_terraform(project.network, 'shared-monitoring') } }
  }

  post {
    always { deleteDir() }
    success { slackSend(message: "\"Apply\" of \"${project.network_version}\" completed on \"${env.ENVIRONMENT}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'good') }
    failure { slackSend(message: "\"Apply\" of \"${project.network_version}\" failed on \"${env.ENVIRONMENT}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'danger') }
  }
}
