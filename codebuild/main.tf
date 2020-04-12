module "codebuild_ecs" {
  source = "./modules"

  account_id         = data.aws_caller_identity.self.account_id
  iam_role_codebuild = aws_iam_role.codebuild.arn
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "CodeBuildServiceRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild.json
}

resource "aws_iam_policy" "codebuild" {
  name   = "CodeBuildServicePolicy"
  policy = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild.arn
}
