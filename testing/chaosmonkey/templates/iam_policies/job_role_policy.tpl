{
  "Version": "2012-10-17",
  "Statement": [
      {
      "Sid": "Stmt1357739573947",
      "Action": [
        "ec2:CreateTags",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumes",
        "ec2:TerminateInstances",
        "ses:SendEmail"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt1357739649609",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}