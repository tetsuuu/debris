// IAMユーザーの名前出力
output "user_name" {
  value = aws_iam_user.default.name
}
