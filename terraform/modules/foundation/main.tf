# Foundation: the objects everything else hangs off.
# AWS Connect lab equivalent: IAM roles and groups, security profiles, routing profile skills, contact attributes.

data "genesyscloud_auth_division_home" "home" {}

resource "genesyscloud_auth_division" "this" {
  for_each    = var.divisions
  name        = "${var.prefix} ${each.key}"
  description = each.value
}

resource "genesyscloud_routing_skill" "this" {
  for_each = toset(var.skills)
  name     = "${var.prefix}-${each.value}"
}

resource "genesyscloud_routing_language" "this" {
  for_each = toset(var.languages)
  name     = each.value
}

resource "genesyscloud_routing_wrapupcode" "this" {
  for_each    = var.wrapup_codes
  name        = "${var.prefix} ${each.key}"
  description = each.value
  division_id = data.genesyscloud_auth_division_home.home.id
}

resource "genesyscloud_group" "this" {
  for_each      = var.groups
  name          = "${var.prefix} ${each.key}"
  description   = each.value
  type          = "official"
  visibility    = "public"
  rules_visible = false
  roles_enabled = true
}

# Custom roles. Least privilege: start from nothing and add. The built-in Agent and Supervisor roles are
# still used for the people doing the work; the roles below cover the supporting jobs.
# Role contents come from the root module (locals.tf). Permission strings are checked by Genesys at apply time.
# If one is rejected, the error names it.
resource "genesyscloud_auth_role" "this" {
  for_each    = var.roles
  name        = "${var.prefix} ${each.key}"
  description = each.value.description
  permissions = each.value.permissions
}

# Grant roles to groups, not to people. Joiners and leavers then change group membership only.
# A group can be kept OUT of chosen divisions (for example, analysts never see the restricted reports division).
resource "genesyscloud_group_roles" "this" {
  for_each = var.group_roles
  group_id = genesyscloud_group.this[each.key].id

  dynamic "roles" {
    for_each = each.value.roles

    content {
      role_id      = genesyscloud_auth_role.this[roles.value].id
      division_ids = [for k, d in genesyscloud_auth_division.this : d.id if !contains(each.value.exclude_divisions, k)]
    }
  }
}

# Org-wide presence: one custom status the team actually needs.
resource "genesyscloud_organization_presence_definition" "huddle" {
  system_presence = "Meeting"
  language_labels = {
    en_US = var.presence_label
  }
}

# Agent capacity: how many contacts one agent can hold at once, per media type.
# Voice is 1 (never double-book a call). Messaging allows more, and can be interrupted by a call.
resource "genesyscloud_routing_utilization" "org" {
  call {
    maximum_capacity = 1
    include_non_acd  = true
  }
  message {
    maximum_capacity          = 3
    include_non_acd           = false
    interruptible_media_types = ["call"]
  }
  chat {
    maximum_capacity          = 3
    include_non_acd           = false
    interruptible_media_types = ["call"]
  }
  email {
    maximum_capacity          = 2
    include_non_acd           = false
    interruptible_media_types = ["call", "message", "chat"]
  }
}

# Speech and text transcription with automatic redaction of card numbers and personal information.
# AWS Connect lab equivalent: Contact Lens PII redaction.
resource "genesyscloud_routing_settings" "org" {
  reset_agent_on_presence_change = true

  transcription {
    transcription                      = "EnabledGlobally"
    content_search_enabled             = true
    pci_dss_redaction_enabled          = true
    pii_redaction_enabled              = true
    transcription_confidence_threshold = 50
  }
}
