output "chatbot_actions_repository_uri" {
  value = aws_ecr_repository.chatbot_actions.repository_url
}

output "www_record_name" {
  value = aws_route53_record.www.name
}
