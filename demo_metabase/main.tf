module "metabase_alb" {
  source = "./modules/alb"

  service_name = var.service_name
  default_vpc  = var.service_vpc
  lb_sg        = [aws_security_group.alb_sg.id]

  lb_subnets = var.public_subnet
  cert_arn = aws_acm_certificate_validation.acm_certificate_validation_metabase.certificate_arn
}

module "metabase_ecs" {
  source = "./modules/ecs"

  vpc_id           = var.service_vpc
  ecs_cluster_name = "maintenance"
  lb_target        = module.metabase_alb.target_arn
  lb_dimension     = module.metabase_alb.alb_dimension
  container_label  = "v0.35.3"
  image_name       = "metabase/metabase"
  service_name     = var.service_name
  db_dbname        = "metabase"
  db_host          = "hogehoge"
  db_user          = "metabase"
  db_pass          = aws_ssm_parameter.db_conn.arn

  ecs_sgs     = [aws_security_group.ecs_sg.id]
  ecs_subnets = var.private_subnet
}

resource "aws_security_group" "ecs_sg" {
  name        = "metabase_ecs"
  description = "For metabase"
  vpc_id      = var.service_vpc

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    security_groups = [aws_security_group.alb_sg.id]

    self = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = var.service_name
  description = "${var.service_name} ALB security Group"
  vpc_id      = var.service_vpc

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "metabase" {
  zone_id = var.delegate_domain_id
  name    = "${var.service_name}.${var.delegate_domain}"
  type    = "A"

  alias {
    name                   = module.metabase_alb.alb_dns
    zone_id                = module.metabase_alb.alb_zone
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "metabase" {
  domain_name       = "${var.service_name}.${var.delegate_domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "acm_certificate_validation_metabase" {
  certificate_arn         = aws_acm_certificate.metabase.arn
  validation_record_fqdns = [aws_route53_record.r53_record_acm_metabase.fqdn]
}

resource "aws_route53_record" "r53_record_acm_metabase" {
  name    = aws_acm_certificate.metabase.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.metabase.domain_validation_options[0].resource_record_type
  zone_id = var.delegate_domain_id
  records = [
    aws_acm_certificate.metabase.domain_validation_options[0].resource_record_value
  ]
  ttl = 60
}

data "sops_file" "secret" {
  source_file = "secret.yml"
}

resource "aws_ssm_parameter" "db_conn" {
  name   = "/ecs/${var.service_name}/db_conn"
  type   = "SecureString"
  key_id = "alias/aws/ssm"
  value  = data.sops_file.secret.data["ecs_db_conn"]
}
