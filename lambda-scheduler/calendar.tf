#-------------------------------------------------------------
### Getting the current running account id
#-------------------------------------------------------------
data "aws_caller_identity" "current" {}


locals {
  account_id     = "${data.aws_caller_identity.current.account_id}"
  assume_role    = "${var.environment_name}-auto-start-role"
  event_role     = "${var.environment_name}-event-role"
  calendar_name  = "${var.environment_name}-calendar"
  start_doc_arn  = "${aws_ssm_document.start.arn}"
  stop_doc_arn  = "${aws_ssm_document.stop.arn}"

}

#-------------------------------------------------------------
### SSM documents
#-------------------------------------------------------------

#Start SSM Document
resource "aws_ssm_document" "start" {
  name              = "${var.environment_name}-start-ec2"
  document_type     = "Automation"
  document_format   = "YAML"
  target_type       = "/AWS::Lambda::Function"
  tags              = "${var.tags}"

  content = <<DOC
  description: '## Starts EC2 instances based on Calendar State'
  schemaVersion: '0.3'
  assumeRole: 'arn:aws:iam::${local.account_id}:role/${local.assume_role}'
  mainSteps:
    - name: checkChangeCalendarOpen
      action: 'aws:assertAwsResourceProperty'
      onFailure: Abort
      timeoutSeconds: 600
      inputs:
        Service: ssm
        Api: GetCalendarState
        CalendarNames:
          - 'arn:aws:ssm:${var.region}:${local.account_id}:document/${local.calendar_name}'
        PropertySelector: $.State
        DesiredValues:
          - CLOSED
      nextStep: startInstances
    - name: startInstances
      action: 'aws:invokeLambdaFunction'
      onFailure: Abort
      timeoutSeconds: 120
      inputs:
        InvocationType: RequestResponse
        FunctionName: "${var.environment_name}-start-ec2"
DOC
}

#Stop SSM Document
resource "aws_ssm_document" "stop" {
  name              = "${var.environment_name}-stop-ec2"
  document_type     = "Automation"
  document_format   = "YAML"
  target_type       = "/AWS::Lambda::Function"
  tags              = "${var.tags}"

  content = <<DOC
  description: '## Stops EC2 instances based on Calendar State'
  schemaVersion: '0.3'
  assumeRole: 'arn:aws:iam::${local.account_id}:role/${local.assume_role}'
  mainSteps:
    - name: checkChangeCalendarOpen
      action: 'aws:assertAwsResourceProperty'
      onFailure: Abort
      timeoutSeconds: 600
      inputs:
        Service: ssm
        Api: GetCalendarState
        CalendarNames:
          - 'arn:aws:ssm:${var.region}:${local.account_id}:document/${local.calendar_name}'
        PropertySelector: $.State
        DesiredValues:
          - OPEN
      nextStep: stopInstances
    - name: stopInstances
      action: 'aws:invokeLambdaFunction'
      onFailure: Abort
      timeoutSeconds: 120
      inputs:
        InvocationType: RequestResponse
        FunctionName: "${var.environment_name}-stop-ec2"
DOC
}

#Change Calendar
###Not yet supported in Terraform as new AWS Service
#####Below info was obtained from an import
###Document Type- ChangeCalendar and document_format TEXT are not recognised by terraform
#Workaround is to create Calendar by other means until it is possible with Terraform

#resource "aws_ssm_document" "calendar" {
#  name              = "${local.calendar_name}"
#  document_type     = "ChangeCalendar"
#  document_format   = "TEXT"
#  tags              = "${var.tags}"

#  content = <<DOC
#BEGIN:VCALENDAR
#PRODID:-//AWS//Change Calendar 1.0//EN
#VERSION:2.0
#X-CALENDAR-TYPE:DEFAULT_OPEN
#X-WR-CALDESC:Calendar to schedule availability of EC2 instances
#BEGIN:VTODO
#DTSTAMP:20200325T184928Z
#UID:a83d5583-6543-4c12-86a5-fda2b19eddf1
#SUMMARY:Add events to this calendar.
#END:VTODO
#END:VCALENDAR
#DOC
#}


#-------------------------------------------------------------
### IAM
#-------------------------------------------------------------
#Policies
resource "aws_iam_policy" "event" {
  name        = "${local.event_role}-policy"
  description = "Policy to allow Event rule to invoke SSM Document"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ssm:StartAutomationExecution",
      "Effect": "Allow",
      "Resource": [
          "arn:aws:ssm:${var.region}:${local.account_id}:automation-definition/${var.environment_name}-start-ec2:$DEFAULT",
          "arn:aws:ssm:${var.region}:${local.account_id}:automation-definition/${var.environment_name}-stop-ec2:$DEFAULT"
      ]
    }
   ]
}
EOF
}

resource "aws_iam_policy" "assume" {
  name        = "${local.assume_role}-policy"
  description = "Policy to allow SSM Automation to invoke Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "cloudwatch:PutMetricData",
          "ds:CreateComputer",
          "ds:DescribeDirectories",
          "ec2:DescribeInstanceStatus",
          "logs:*",
          "ssm:*",
          "ec2messages:*"
      ],
      "Resource": "*"
  },
  {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*",
      "Condition": {
          "StringLike": {
              "iam:AWSServiceName": "ssm.amazonaws.com"
          }
      }
  },
  {
      "Effect": "Allow",
      "Action": [
          "iam:DeleteServiceLinkedRole",
          "iam:GetServiceLinkedRoleDeletionStatus"
      ],
      "Resource": "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"
  },
  {
      "Effect": "Allow",
      "Action": [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
  },
  {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateImage",
          "ec2:CopyImage",
          "ec2:DeregisterImage",
          "ec2:DescribeImages",
          "ec2:DeleteSnapshot",
          "ec2:StartInstances",
          "ec2:RunInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags",
          "cloudformation:CreateStack",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStacks",
          "cloudformation:UpdateStack",
          "cloudformation:DeleteStack"
      ],
      "Resource": [
          "*"
      ]
  },
  {
      "Effect": "Allow",
      "Action": [
          "ssm:*"
      ],
      "Resource": [
          "*"
      ]
  },
  {
      "Effect": "Allow",
      "Action": [
          "sns:Publish"
      ],
      "Resource": [
          "arn:aws:sns:*:*:Automation*"
      ]
  },
  {
      "Effect": "Allow",
      "Action": [
          "lambda:InvokeFunction"
      ],
      "Resource": [
          "*"
      ]
  },
  {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::${local.account_id}:role/${local.assume_role}"
  }
]
}
EOF
}


#IAM Roles

resource "aws_iam_role" "assume" {
  name = "${local.assume_role}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ssm.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


resource "aws_iam_role" "event" {
  name = "${local.event_role}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

#IAM Policy attachment

resource "aws_iam_role_policy_attachment" "assume" {
  role       = "${aws_iam_role.assume.name}"
  policy_arn = "${aws_iam_policy.assume.arn}"
}

resource "aws_iam_role_policy_attachment" "event" {
  role       = "${aws_iam_role.event.name}"
  policy_arn = "${aws_iam_policy.event.arn}"
}


################################################
#
#            CLOUDWATCH EVENT
#
################################################

resource "aws_cloudwatch_event_rule" "start" {
  name                = "${var.environment_name}-start-ec2"
  description         = "Auto Start of EC2 Instances"
  schedule_expression = "rate(5 minutes)"
  is_enabled          = "false"
}

resource "aws_cloudwatch_event_target" "start" {
  arn           = "${replace(local.start_doc_arn, "document/", "automation-definition/")}"
  rule          = "${aws_cloudwatch_event_rule.start.name}"
  role_arn      = "${aws_iam_role.event.arn}"
}


resource "aws_cloudwatch_event_rule" "stop" {
  name                = "${var.environment_name}-stop-ec2"
  description         = "Auto Stop of EC2 Instances"
  schedule_expression = "rate(5 minutes)"
  is_enabled          = "false"
}

resource "aws_cloudwatch_event_target" "stop" {
  arn           = "${replace(local.stop_doc_arn, "document/", "automation-definition/")}"
  rule          = "${aws_cloudwatch_event_rule.stop.name}"
  role_arn      = "${aws_iam_role.event.arn}"
}
