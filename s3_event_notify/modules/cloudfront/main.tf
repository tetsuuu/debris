locals {
  bucket_id = "S3-${aws_s3_bucket.default.bucket}"
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "for poc to DNS failover"
}

resource "aws_cloudfront_distribution" "default" {
  enabled = true

  origin {
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }

    domain_name = aws_s3_bucket.default.bucket_domain_name
    origin_id   = local.bucket_id
  }

  aliases = [
    "${aws_s3_bucket.default.bucket}.${var.delegate_domain}"
  ]

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]
    cached_methods = [
      "GET",
      "HEAD"
    ]
    target_origin_id       = local.bucket_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}
