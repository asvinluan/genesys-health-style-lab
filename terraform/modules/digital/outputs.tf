output "deployment_id" {
  description = "Paste this into the website snippet from the Genesys admin page."
  value       = genesyscloud_webdeployments_deployment.chat.id
}
