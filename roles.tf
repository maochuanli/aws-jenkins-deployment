data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "admin_policy" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "slave_role" {
  name               = "jenkins_slave_role_${var.env}"
  path               = "/jenkins/"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"

  tags = {
    Name = "jenkins_slave_role"
  }
}

resource "aws_iam_role_policy_attachment" "admin-role-policy-attach" {
  role       = "${aws_iam_role.slave_role.name}"
  policy_arn = "${data.aws_iam_policy.admin_policy.arn}"
}


resource "aws_iam_policy" "master_jenkins_policy" {
  name = "master_jenkins_policy_${var.env}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CreateSlaveVMs",
            "Action": [
                "ec2:DescribeSpotInstanceRequests",
                "ec2:CancelSpotInstanceRequests",
                "ec2:GetConsoleOutput",
                "ec2:RequestSpotInstances",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeRegions",
                "ec2:DescribeImages",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "iam:ListInstanceProfilesForRole",
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": ["ssm:GetParameter", "ssm:GetParametersByPath"],
            "Resource": "arn:aws:ssm:ap-southeast-2:${var.aws_account_no}:parameter/*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "master_role" {
  name               = "jenkins_master_role_${var.env}"
  path               = "/jenkins/"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"

  tags = {
    Name = "jenkins_master_role"
  }
}

resource "aws_iam_role_policy_attachment" "attach_master_role_policy" {
  role       = "${aws_iam_role.master_role.name}"
  policy_arn = "${aws_iam_policy.master_jenkins_policy.arn}"
}

resource "aws_iam_instance_profile" "master_instance_profile" {
  name = "master_instance_profile_${var.env}"
  role = "${aws_iam_role.master_role.name}"
}

resource "aws_iam_instance_profile" "slave_instance_profile" {
  name = "slave_instance_profile_${var.env}"
  role = "${aws_iam_role.slave_role.name}"
}
