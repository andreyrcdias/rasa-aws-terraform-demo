resource "aws_s3_bucket" "webchat_static" {
  bucket = var.domain_name

  tags = {
    Project     = var.project
    Name        = "StaticWebsite"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_cors_configuration" "webchat_cors" {
  bucket = aws_s3_bucket.webchat_static.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "webchat_bucket_policy" {
  bucket = aws_s3_bucket.webchat_static.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource = [
        "arn:aws:s3:::${aws_s3_bucket.webchat_static.id}/*"
      ]
    }]
  })
}

resource "aws_s3_bucket_website_configuration" "webchat_config" {
  bucket = aws_s3_bucket.webchat_static.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "webchat_owner" {
  bucket = aws_s3_bucket.webchat_static.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "webchat_acl" {
  bucket = aws_s3_bucket.webchat_static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}

resource "aws_s3_object" "website_index" {
  bucket       = aws_s3_bucket.webchat_static.bucket
  key          = "index.html"
  source       = "../web/index.html"
  content_type = "text/html"

  tags = {
    Project = var.project
    Name    = var.app_name
  }
}

resource "aws_s3_object" "website_error" {
  bucket       = aws_s3_bucket.webchat_static.bucket
  key          = "error.html"
  source       = "../web/error.html"
  content_type = "text/html"

  tags = {
    Project = var.project
    Name    = var.app_name
  }
}

# resource "aws_s3_object" "webchat_favicon" {
#   bucket       = aws_s3_bucket.webchat_static.bucket
#   key          = "favicon.ico"
#   source       = "../web/favicon.ico"
#   content_type = "image/x-icon"
#
#   tags = {
#     Project = var.project
#     Name    = var.app_name
#   }
# }
#
# resource "aws_s3_object" "webchat_css" {
#   bucket       = aws_s3_bucket.webchat_static.bucket
#   key          = "style.css"
#   source       = "../web/style.css"
#   content_type = "text/css"
#
#   tags = {
#     Project = var.project
#     Name    = var.app_name
#   }
# }
#
# resource "aws_s3_object" "webchat_script" {
#   bucket       = aws_s3_bucket.webchat_static.bucket
#   key          = "script.js"
#   source       = "../web/script.js"
#   content_type = "text/javascript"
#
#   tags = {
#     Project = var.project
#     Name    = var.app_name
#   }
# }

resource "aws_cloudfront_distribution" "static_site_distribution" {
  origin {
    origin_id   = var.app_name
    domain_name = "${aws_s3_bucket.webchat_static.bucket}.s3-website-${var.aws_region}.amazonaws.com"

    // The custom_origin_config is for the website endpoint settings configured via the AWS Console.
    // https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CustomOriginConfig.html
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }
    connection_attempts = 3
    connection_timeout  = 10
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [var.domain_name, "www.${var.domain_name}", "api.${var.domain_name}", "actions.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.app_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Project     = var.project
    Name        = "StaticWebsite"
    Environment = "Production"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    ssl_support_method             = "sni-only"
    acm_certificate_arn            = var.acm_certificate_arn
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

resource "aws_route53_record" "landing_page_A_record" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name = aws_cloudfront_distribution.static_site_distribution.domain_name
    // https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-route53-recordset-aliastarget.html
    // This is always the hosted zone ID when you create an alias record that routes traffic to a CloudFront distribution.
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }
}

