# Architect: the call flows, the lookup tables and the number-to-flow wiring.
# AWS Connect lab equivalent: contact flows, flow modules, DynamoDB lookup tables, phone-number-to-flow association.

locals {
  # Every queue becomes a placeholder a flow can use: "Visa General" becomes {{queue_visa_general}}.
  queue_subs = { for k, v in var.queue_names : "queue_${lower(replace(k, " ", "_"))}" => v }
}

# ---------------------------------------------------------------- flows
# One resource per flow template in the flows folder. The names are injected, so a queue rename
# in one place cannot break a menu.
resource "genesyscloud_flow" "this" {
  for_each = var.flows
  filepath = "${var.flows_dir}/${each.value.file}"

  substitutions = merge(local.queue_subs, {
    flow_name     = "${var.prefix} ${each.value.name}"
    division_name = var.division_name
  })
}

# ---------------------------------------------------------------- data tables
# Lookup tables that a flow can read without calling an outside system.
# AWS Connect lab equivalent: the DynamoDB tables (customer accounts, holiday calendar).
# Business teams can change a row without a flow release. That is the point.

resource "genesyscloud_architect_datatable" "routing_config" {
  name        = "${var.prefix} Routing Config"
  division_id = var.division_id
  description = "Feature switches and messages the flows read at run time."

  properties {
    name  = "key"
    type  = "string"
    title = "Setting"
  }
  properties {
    name  = "value"
    type  = "string"
    title = "Value"
  }
  properties {
    name  = "note"
    type  = "string"
    title = "Note"
  }
}

resource "genesyscloud_architect_datatable_row" "config_wait_message" {
  datatable_id = genesyscloud_architect_datatable.routing_config.id
  key_value    = "high_wait_message"
  properties_json = jsonencode({
    "value" = "We are experiencing high call volumes."
    "note"  = "Played when estimated wait exceeds the threshold."
  })
}

resource "genesyscloud_architect_datatable_row" "config_wait_threshold" {
  datatable_id = genesyscloud_architect_datatable.routing_config.id
  key_value    = "high_wait_threshold_seconds"
  properties_json = jsonencode({
    "value" = "300"
    "note"  = "Offer a callback above this estimated wait."
  })
}

resource "genesyscloud_architect_datatable" "surge_notices" {
  name        = "${var.prefix} Surge Notices"
  division_id = var.division_id
  description = "Notices the surge flow can announce. Fictional exercise data."

  properties {
    name  = "key"
    type  = "string"
    title = "Notice code"
  }
  properties {
    name  = "event"
    type  = "string"
    title = "Announcement"
  }
  properties {
    name    = "priority"
    type    = "integer"
    title   = "Priority boost"
    default = "5"
  }
}

resource "genesyscloud_architect_datatable_row" "surge_rows" {
  for_each     = var.surge_notices
  datatable_id = genesyscloud_architect_datatable.surge_notices.id
  key_value    = each.key
  properties_json = jsonencode({
    "event"    = each.value
    "priority" = 5
  })
}

# ---------------------------------------------------------------- number to flow
# One IVR config per number. It names the flow for each hours state and the schedule group that decides which applies.
resource "genesyscloud_architect_ivr" "this" {
  for_each = var.lines

  name               = "${var.prefix} ${each.key}"
  description        = each.value.description
  dnis               = each.value.dnis
  open_hours_flow_id = genesyscloud_flow.this[each.value.open_flow].id
  schedule_group_id  = var.schedule_group_ids[each.value.schedule_group]

  closed_hours_flow_id  = each.value.closed_flow == null ? null : genesyscloud_flow.this[each.value.closed_flow].id
  holiday_hours_flow_id = each.value.holiday_flow == null ? null : genesyscloud_flow.this[each.value.holiday_flow].id
}

# ---------------------------------------------------------------- surge switch
# An emergency group overrides the normal flow on the listed numbers the moment it is enabled.
# Flip surge_mode_enabled and apply, or enable the group in the Architect screen, to move the main lines to the surge flow.
# AWS Connect lab equivalent: the break-glass flow behind a single switch.

resource "genesyscloud_architect_emergencygroup" "surge" {
  name        = "${var.prefix} Surge Override"
  description = "Sends the chosen lines to the surge flow while a surge or major event is active."
  enabled     = var.surge_mode_enabled

  emergency_call_flows {
    emergency_flow_id = genesyscloud_flow.this[var.surge_flow].id
    ivr_ids           = [for k, l in var.lines : genesyscloud_architect_ivr.this[k].id if l.surge_override]
  }
}

# Process automation trigger. AWS Connect lab equivalent: an EventBridge rule that starts a Step Functions state machine.
# Genesys publishes events on topics. The trigger listens to one and starts the workflow.
resource "genesyscloud_processautomation_trigger" "contact_end" {
  count = var.enable_event_trigger ? 1 : 0

  name       = "${var.prefix} Contact Ended"
  topic_name = "v2.detail.events.conversation.{id}.customer.end"
  enabled    = true

  target {
    id   = genesyscloud_flow.this[var.event_workflow].id
    type = "Workflow"

    workflow_target_settings {
      data_format = "TopLevelPrimitives"
    }
  }
}
