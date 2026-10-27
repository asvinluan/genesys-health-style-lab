output "queue_lookup_action_id" {
  value = genesyscloud_integration_action.queue_lookup.id
}

output "normalise_reference_action_id" {
  value = genesyscloud_integration_action.normalise_reference.id
}

output "case_status_action_id" {
  value = var.enable_case_api ? genesyscloud_integration_action.case_status[0].id : ""
}
