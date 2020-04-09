resource "aws_route53_record" "default" {
  name            = "${var.bucket_name}.${var.delegate_domain}"
  type            = "A"
  zone_id         = var.zone_id

  alias {
    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id
    name                   = aws_cloudfront_distribution.default.domain_name
    evaluate_target_health = false
  }
}
