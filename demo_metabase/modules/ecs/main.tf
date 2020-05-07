# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "maintenance"  //var.service_name
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 300

  load_balancer {
    target_group_arn = var.lb_target
    container_name   = var.service_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets         = var.ecs_subnets
    security_groups = var.ecs_sgs
  }

  depends_on = [var.lb_target]
}

resource "aws_cloudwatch_log_group" "service" {
  name  = "/ecs/${var.service_name}"
}

data "template_file" "service" {
  template = file("${path.module}/task_definitions/task_template.tpl")

  vars = {
    container_name = var.service_name
    image_name     = var.image_name
    label          = var.container_label
    log_group      = aws_cloudwatch_log_group.service.name
    mb_db_type     = var.db_type
    mb_db_dbname   = var.db_dbname
    mb_db_port     = var.db_port
    mb_db_user     = var.db_user
    mb_db_pass     = var.db_pass
    mb_db_host     = var.db_host
    secret_params  = var.db_pass
    region         = "ap-northeast-1"
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task.arn
  cpu                      = "512"
  memory                   = "2048"
  container_definitions    = data.template_file.service.rendered

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "assume_ecs" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_ecs_task" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.service_name}ExecutionTaskRole"

  assume_role_policy = data.aws_iam_policy_document.assume_ecs_task.json
}

data "aws_iam_policy_document" "iam_policy_document_get_secret" {

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:ap-northeast-1:652679745562:parameter/demo/metabase/db-conn",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_task_policy_get_secret" {
  name = "${var.service_name}Policy"

  policy = data.aws_iam_policy_document.iam_policy_document_get_secret.json
}

resource "aws_iam_role_policy_attachment" "attachment_ecs_task_role_get_secret" {
  policy_arn = aws_iam_policy.ecs_task_policy_get_secret.arn
  role       = aws_iam_role.ecs_task.name
}
