resource "aws_cloudwatch_metric_alarm" "ecs_task_scale_in" {
  alarm_name          = "${var.service_name}ScaleIn"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  statistic           = "Average"
  period              = 300
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  alarm_description   = "This metric monitor is for ${var.service_name} scale in"
  alarm_actions       = [aws_appautoscaling_policy.service_scale_in.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_task_scale_out" {
  alarm_name          = "${var.service_name}ScaleOut"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  statistic           = "Sum"
  period              = 60
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_description   = "This metric monitor is for ${var.service_name} scale out"
  alarm_actions       = [aws_appautoscaling_policy.service_scale_out.arn]

  dimensions = {
    LoadBalancer = var.lb_dimension
  }
}

resource "aws_appautoscaling_target" "ecs_task" {
  max_capacity       = 1
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "service_scale_in" {
  name               = "${var.service_name}ScaleIn"
  service_namespace  = aws_appautoscaling_target.ecs_task.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_task.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_task.scalable_dimension
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_appautoscaling_policy" "service_scale_out" {
  name               = "${var.service_name}ScaleOut"
  service_namespace  = aws_appautoscaling_target.ecs_task.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_task.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_task.scalable_dimension
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}
