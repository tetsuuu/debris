resource "aws_codebuild_project" "codebuild_ecs_desired_change" {
  name           = "CodeBuildServiceDesiredCountChange"
  description    = "Change services desired count for insident"
  badge_enabled  = false
  encryption_key = "arn:aws:kms:ap-northeast-1:${var.account_id}:alias/aws/s3"
  service_role   = var.iam_role_codebuild

  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    type                   = "NO_ARTIFACTS"
  }

  cache {
    modes = []
    type  = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "action"
      value = "stop"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "cluster"
      value = "hoge"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "service"
      value = "fuga"
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = "codebuild/modules/src/buildspec.yml"
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = "https://github.com/tetsuuu/debris.git"
    report_build_status = false
    type                = "GITHUB"

    auth {
      type     = "OAUTH"
      resource = aws_codebuild_source_credential.codebuild.arn
    }
  }
}

resource "aws_codebuild_source_credential" "codebuild" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = ""
}
