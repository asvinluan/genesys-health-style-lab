output "inbound_numbers" {
  description = "Numbers to dial in the test call."
  value       = { for k, l in local.lines : k => l.dnis }
}

output "queue_ids" {
  value = module.routing.queue_ids
}

output "web_deployment_id" {
  description = "Paste into the website snippet."
  value       = try(module.digital[0].deployment_id, "")
}

output "knowledge_base_id" {
  value = try(module.ai[0].knowledge_base_id, "")
}

output "sign_in_hardening_applied" {
  value = module.security.hardening_applied
}

output "surge_group_enabled" {
  description = "True while the surge switch is on and the surge flow overrides the lines that allow it."
  value       = module.architect.surge_group_enabled
}

output "queues_without_recording" {
  description = "Queues that are deliberately NOT in the recording retention policy. Check this list in review."
  value       = [for k in sort(keys(local.queues)) : k if !contains(local.recorded_queue_keys, k)]
}
