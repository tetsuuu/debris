// IAMグループリソース
resource "aws_iam_group" "default" {
  name = var.group
}

// IAMポリシーアタッチ
resource "aws_iam_group_policy_attachment" "default" {
  for_each   = var.policy_arns
  group      = aws_iam_group.default.id
  policy_arn = each.value
}
