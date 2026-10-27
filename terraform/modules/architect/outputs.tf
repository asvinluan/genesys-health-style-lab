output "flow_ids" {
  value = { for k, f in genesyscloud_flow.this : k => f.id }
}

output "ivr_ids" {
  value = { for k, i in genesyscloud_architect_ivr.this : k => i.id }
}

output "datatable_ids" {
  value = {
    routing_config = genesyscloud_architect_datatable.routing_config.id
    surge_notices  = genesyscloud_architect_datatable.surge_notices.id
  }
}

output "surge_group_enabled" {
  value = genesyscloud_architect_emergencygroup.surge.enabled
}
