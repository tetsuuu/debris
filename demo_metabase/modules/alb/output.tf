output "alb_dns" {
  value = aws_alb.alb.dns_name
}

output "alb_zone" {
  value = aws_alb.alb.zone_id
}

output "alb_dimension" {
  value = aws_alb.alb.arn_suffix
}

output "listener_http" {
  value = aws_alb_listener.alb_listener_http
}

output "target_arn" {
  value = aws_alb_target_group.service.arn
}
