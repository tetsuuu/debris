// デフォルトのIAMポリシーarn出力
output "default_policy" {
  value = aws_iam_policy.default.arn
}

// セッションマネージャー用のIAMポリシーarn出力
output "ssm_policy" {
  value = aws_iam_policy.default_ssm.arn
}
