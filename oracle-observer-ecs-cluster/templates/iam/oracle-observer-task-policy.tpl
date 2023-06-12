{
    "Statement": [
        {
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Effect": "Allow",
            "Resource": [
                "${oradb_sys_password_parameter}"
            ],
            "Sid": "Parameters"
        }
    ],
    "Version": "2012-10-17"
}