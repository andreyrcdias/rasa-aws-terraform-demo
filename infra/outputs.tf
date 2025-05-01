output "chatbot_url" {
  value = "https://${module.web.chatbot_url}"
}

output "actions_url" {
  value = "https://${module.actions.www_record_name}"
}

output "api_url" {
  value = "https://${module.bot.www_record_name}"
}
