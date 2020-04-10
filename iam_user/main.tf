locals {
  hoge = "hogehoge"
  fuga = "fugafuga"
  hoga = "hogefuga"
}

// IAMユーザー作成
module "demo_01" {
  source = "./modules/user"

  name      = "demo_01"
  iam_group = module.hoge_group.group_name
}

module "demo_02" {
  source = "./modules/user"

  name      = "demo_02"
  iam_group = local.fuga
}
module "demo_03" {
  source = "./modules/user"

  name      = "demo_03"
  iam_group = local.hoga
}

// IAMポリシーの作成
module "gengeral_policy" {
  source = "./modules/policy"

  account_id = data.aws_caller_identity.self.account_id
  bastion    = "i-123456abcdefg"
}

// IAMグループの作成
module "hoge_group" {
  source = "./modules/group"

  group      = local.hoge

  policy_arns = {
    default     = module.gengeral_policy.default_policy
    ssm_bastion = module.gengeral_policy.ssm_policy
  }
}

module "fuga_group" {
  source = "./modules/group"

  group      = local.fuga

  policy_arns = {
    ssm_bastion = module.gengeral_policy.ssm_policy
  }
}

module "hoga_group" {
  source = "./modules/group"

  group      = local.hoga

  policy_arns = {
    default     = module.gengeral_policy.default_policy
  }
}

// IAMグループへのメンバー追加
resource "aws_iam_group_membership" "hoge" {
  name = "${local.hoge}Membership"
  group = module.hoge_group.group_name

  users = [
    module.demo_01.user_name,
  ]
}

resource "aws_iam_group_membership" "fuga" {
  name = "${local.fuga}Membership"
  group = module.fuga_group.group_name

  users = [
    module.demo_02.user_name,
  ]
}

resource "aws_iam_group_membership" "hoga" {
  name = "${local.hoga}Membership"
  group = module.hoga_group.group_name

  users = [
    module.demo_03.user_name,
  ]
}
