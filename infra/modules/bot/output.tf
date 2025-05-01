output "chatbot_api_repository_uri" {
  value = aws_ecr_repository.chatbot_api.repository_url
}

output "chatbot_models_bucket_name" {
  value = aws_s3_bucket.chatbot_models.bucket
}

output "chatbot_models_bucket_arn" {
  value = aws_s3_bucket.chatbot_models.arn
}

output "www_record_name" {
  value = aws_route53_record.www.name
}

