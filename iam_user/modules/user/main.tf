resource "aws_iam_user" "default" {
  name          = var.name
  force_destroy = true

  tags = {
    Group = var.iam_group
  }
}
