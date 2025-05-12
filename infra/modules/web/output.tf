output "chatbot_bucket_name" {
  value = aws_s3_bucket.webchat_static.bucket
}

output "chatbot_url" {
  value = aws_route53_record.landing_page_A_record.name
}
