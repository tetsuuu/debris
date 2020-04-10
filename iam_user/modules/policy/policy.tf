data "aws_iam_policy_document" "ssm_policy" {

  statement {
    effect = "Allow"
    actions = [
      "ssm:StartSession",
      "ssm:GetConnectionStatus",
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:instance/${var.bastion}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeSessions",
      "ssm:DescribeInstanceProperties",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession"
    ]
    resources = [
      "arn:aws:ssm:*:*:session/$${aws:username}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "basic_policy" {

  statement {
    effect = "Allow"
    actions = [
      "iam:ListUsers"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:user/"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:ListVirtualMFADevices"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:mfa/"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:EnableMFADevice",
      "iam:DeactivateMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListMFADevices"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:user/$${aws:username}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:DeleteVirtualMFADevice",
      "iam:CreateVirtualMFADevice"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:mfa/$${aws:username}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:UpdateLoginProfile"
    ]
    resources = [
      "arn:aws:iam::${var.account_id}:user/$${aws:username}"
    ]
  }
}