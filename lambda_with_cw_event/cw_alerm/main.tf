resource "aws_cloudwatch_log_metric_filter" "cloudwatch_log_metric_filter" {
  name           = var.cw_filter_name
  log_group_name = var.cw_log_group_name

  pattern = var.cw_filter_pattern

  metric_transformation {
    name          = "${var.cw_filter_name}Count"
    namespace     = var.cw_filter_namespace
    value         = "1"
    default_value = var.cw_default_metric
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_alarm" {
  alarm_name          = var.cw_alarm_name
  comparison_operator = var.cw_alarm_operator
  datapoints_to_alarm = var.cw_datapoints
  evaluation_periods  = var.cw_evaluation_periods
  threshold           = 1
  statistic           = var.cw_alarm_statistic
  period              = var.cw_alarm_period
  metric_name         = aws_cloudwatch_log_metric_filter.cloudwatch_log_metric_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.cloudwatch_log_metric_filter.metric_transformation[0].namespace
  alarm_actions       = var.sns_topic_arns
  treat_missing_data  = "notBreaching"
}
