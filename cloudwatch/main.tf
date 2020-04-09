resource "aws_cloudwatch_metric_alarm" "ecs_compare_tasks" {
  for_each            = var.service_name
  alarm_name          = "${each.key}_running_lessthan_desire"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  threshold           = "0"
  datapoints_to_alarm = "3"
  alarm_actions       = var.sns_topic_arns

  metric_query {
    expression  = "IF(running < desired, 1, 0)"
    id          = "task_less_than_desired"
    label       = "InsufficientTasks"
    return_data = true
  }
  metric_query {
    id          = "desired"
    return_data = false
    metric {
        dimensions  = {
            "ClusterName" = each.value
            "ServiceName" = each.key
        }
        metric_name = "DesiredTaskCount"
        namespace   = "ECS/ContainerInsights"
        period      = 60
        stat        = "Average"
    }
  }
  metric_query {
    id          = "running"
    return_data = false
    metric {
      dimensions  = {
          "ClusterName" = each.value
          "ServiceName" = each.key
      }
      metric_name = "RunningTaskCount"
      namespace   = "ECS/ContainerInsights"
      period      = 60
      stat        = "Average"
    }
  }
}
