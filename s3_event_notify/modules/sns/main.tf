data "aws_iam_policy_document" "sns_topic" {

  statement {
    sid     = "basicPolicy"
    effect  = "Allow"
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["arn:aws:sns:ap-northeast-1:719274672211:poc_kinoshita"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [var.account_id]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["arn:aws:sns:*:*:${var.sns_topic}"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [var.s3_bucket]
    }
  }
}

resource "aws_sns_topic" "sns_topic" {
  name   = var.sns_topic
  policy = data.aws_iam_policy_document.sns_topic.json
}
