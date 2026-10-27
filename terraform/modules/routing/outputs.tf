output "queue_ids" {
  value = { for k, q in genesyscloud_routing_queue.this : k => q.id }
}

output "queue_names" {
  description = "Full queue names as Genesys holds them. Flows refer to queues by name."
  value       = { for k, q in genesyscloud_routing_queue.this : k => q.name }
}

output "schedule_group_ids" {
  description = "Schedule group key to ID. Flows' number configs pick one."
  value       = { for k, g in genesyscloud_architect_schedulegroups.this : k => g.id }
}

output "inqueue_flow_id" {
  value = genesyscloud_flow.inqueue.id
}
