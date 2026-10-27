# Telephony: how calls get in and out of Genesys Cloud.
# AWS Connect lab equivalent: claimed numbers, and the VPC / NAT / endpoint network around the platform.
#
# Design choice: BYOC Cloud (bring your own carrier, but no hardware to run). The carrier's SIP trunk
# connects to Genesys Cloud media in AWS. There is no Edge appliance and no customer VPC to build.
# BYOC Premises (an Edge appliance in your data centre) is the alternative when media must stay on site.

resource "genesyscloud_location" "hq" {
  name  = "${var.prefix} Head Office"
  notes = "Fictional head office. Created for a lab."

  address {
    street1  = var.address.street1
    city     = var.address.city
    state    = var.address.state
    country  = var.address.country
    zip_code = var.address.zip_code
  }

  emergency_number {
    number = var.emergency_number
    type   = "default"
  }
}

resource "genesyscloud_telephony_providers_edges_site" "cloud" {
  name        = "${var.prefix} BYOC Cloud Site"
  description = "Cloud media site. Routes carrier SIP traffic through Genesys Cloud media in ${var.media_region}."
  location_id = genesyscloud_location.hq.id
  media_model = "Cloud"

  media_regions       = [var.media_region]
  caller_id           = var.site_caller_id
  caller_name         = var.caller_name
  set_as_default_site = false

  number_plans {
    name           = "Australian national"
    classification = "national"
    match_type     = "digitLength"

    digit_length {
      start = "10"
      end   = "10"
    }
  }
}

# The SIP trunk to the carrier. G.711 A-law (PCMA) is the standard codec on Australian networks, with u-law as fallback.
resource "genesyscloud_telephony_providers_edges_trunkbasesettings" "carrier" {
  name               = "${var.prefix} Carrier SIP Trunk"
  description        = "BYOC Cloud trunk to ${var.carrier_label}"
  trunk_meta_base_id = "external_sip_pcv_byoc_carrier.json"
  trunk_type         = "EXTERNAL"
  inbound_site_id    = genesyscloud_telephony_providers_edges_site.cloud.id
  managed            = false

  properties = jsonencode({
    "trunk_label" = {
      "value" = {
        "instance" = "${var.prefix} ${var.carrier_label}"
      }
    }
    "trunk_max_dial_timeout" = {
      "value" = {
        "instance" = "1m"
      }
    }
    "trunk_transport_sip_dscp_value" = {
      "value" = {
        "instance" = 46
      }
    }
    "trunk_media_disconnect_on_idle_rtp" = {
      "value" = {
        "instance" = true
      }
    }
    "trunk_media_codec" = {
      "value" = {
        "instance" = ["audio/pcma", "audio/pcmu"]
      }
    }
  })
}

# The range of numbers the carrier gave you. Genesys needs to know they are yours before it will route them.
resource "genesyscloud_telephony_providers_edges_did_pool" "range" {
  start_phone_number = var.did_range_start
  end_phone_number   = var.did_range_end
  description        = "${var.prefix} carrier number range"
  comments           = "Fictional drama-range numbers. Replace with the carrier-assigned range."
  pool_provider      = "PURE_CLOUD"
}
