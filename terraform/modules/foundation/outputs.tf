output "home_division_id" {
  value = data.genesyscloud_auth_division_home.home.id
}

output "division_ids" {
  description = "Division name to ID."
  value       = { for k, d in genesyscloud_auth_division.this : k => d.id }
}

output "skill_ids" {
  value = { for k, s in genesyscloud_routing_skill.this : k => s.id }
}

output "language_ids" {
  value = { for k, l in genesyscloud_routing_language.this : k => l.id }
}

output "wrapup_code_ids" {
  value = { for k, w in genesyscloud_routing_wrapupcode.this : k => w.id }
}

output "group_ids" {
  value = { for k, g in genesyscloud_group.this : k => g.id }
}

output "integration_role_id" {
  description = "Role granted to the data-action OAuth client."
  value       = genesyscloud_auth_role.this[var.integration_role_name].id
}

output "role_ids" {
  value = { for k, r in genesyscloud_auth_role.this : k => r.id }
}
