output "site_id" {
  value = genesyscloud_telephony_providers_edges_site.cloud.id
}

output "trunk_base_settings_id" {
  value = genesyscloud_telephony_providers_edges_trunkbasesettings.carrier.id
}

output "location_id" {
  value = genesyscloud_location.hq.id
}
