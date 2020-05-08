resource "aws_alb" "alb" {
  name = "${var.service_name}-alb"

  internal           = var.lb_is_internal
  load_balancer_type = "application"

  security_groups = var.lb_sg
  subnets         = var.lb_subnets

  enable_deletion_protection = false

  idle_timeout = 300
}

resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "alb_listener_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.cert_arn

  default_action {
    target_group_arn =  aws_alb_target_group.service.arn
    type             = "forward"
  }
}


resource "aws_alb_target_group" "service" {
  name        = "${var.service_name}-target"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.default_vpc
  target_type = "ip"

  health_check {
    interval            = 30
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}
