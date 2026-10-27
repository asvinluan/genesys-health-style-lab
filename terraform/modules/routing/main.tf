# Routing: when we are open, who answers, and how a queue grows when it is busy.
# AWS Connect lab equivalent: hours of operation, queues, routing profiles (priority and delay), the customer queue flow.

resource "genesyscloud_flow" "inqueue" {
  filepath = "${var.flows_dir}/inqueue.yaml"

  substitutions = {
    flow_name     = "${var.prefix} In-Queue Hold"
    division_name = var.home_division_name
  }
}

# ---------------------------------------------------------------- schedules
# Genesys works in three kinds of schedule: open, closed and holiday. A schedule group bundles them for one line.
# The group answers one question for the call: open, closed or holiday?

resource "genesyscloud_architect_schedules" "open" {
  for_each    = var.open_schedules
  name        = "${var.prefix} ${each.key}"
  description = each.value.description
  start       = each.value.start
  end         = each.value.end
  rrule       = each.value.rrule
}

resource "genesyscloud_architect_schedules" "holiday" {
  for_each    = var.holidays
  name        = "${var.prefix} Holiday ${each.key}"
  description = "Public holiday: the line follows its holiday flow"
  start       = "${each.value}T00:00:00.000000"
  end         = "${formatdate("YYYY-MM-DD", timeadd("${each.value}T00:00:00Z", "24h"))}T00:00:00.000000"
}

resource "genesyscloud_architect_schedulegroups" "this" {
  for_each             = var.schedule_groups
  name                 = "${var.prefix} ${each.key}"
  description          = each.value.description
  time_zone            = var.time_zone
  open_schedules_id    = [for s in each.value.open : genesyscloud_architect_schedules.open[s].id]
  holiday_schedules_id = each.value.use_holidays ? [for h in genesyscloud_architect_schedules.holiday : h.id] : null
}

# ---------------------------------------------------------------- queues
# One queue per business outcome, not one per skill. Skills decide WHICH agent in the queue, rings decide WHEN to widen the pool.
# Ring 1 is the base group. Each overflow entry adds another group after a wait: the same idea as
# routing-profile priority and delay in Amazon Connect.
#
# Genesys rule (found by testing, confirmed by Genesys staff on the community forum): bullseye routing needs at least
# TWO rings, and the last ring is "route to all agents in the queue" with no group attached. So a queue with N overflow
# entries gets N + 2 rings: base group, one ring per overflow group, then the empty "everyone" ring. A queue with no
# overflow entries gets no rings at all (plain routing). Genesys allows 6 rings, so 4 overflow entries at most.
# Ring timeouts are how long each ring waits before widening. The overflow list gives the TOTAL seconds in the queue,
# so each ring's wait is the difference between two neighbours.

locals {
  rings = {
    for k, q in var.queues : k => length(q.overflow) == 0 ? [] : concat(
      [{ group = q.base_group, wait = q.overflow[0].after_seconds }],
      [
        for i, o in q.overflow : {
          group = o.group
          wait  = i + 1 < length(q.overflow) ? q.overflow[i + 1].after_seconds - o.after_seconds : var.last_ring_wait_seconds
        }
      ],
      [{ group = null, wait = 5 }]
    )
  }

  # Every group a queue can ever use must be a member of the queue, so list them all once.
  queue_groups = {
    for k, q in var.queues : k => distinct(concat(
      [q.base_group],
      [for o in q.overflow : o.group],
      [for s in q.surge : s.group]
    ))
  }
}

resource "genesyscloud_routing_queue" "this" {
  for_each = var.queues

  name                    = "${var.prefix} ${each.key}"
  description             = each.value.description
  division_id             = var.division_ids[each.value.division]
  acw_wrapup_prompt       = "MANDATORY_TIMEOUT"
  acw_timeout_ms          = each.value.acw_seconds * 1000
  skill_evaluation_method = "BEST"
  queue_flow_id           = genesyscloud_flow.inqueue.id
  enable_transcription    = each.value.transcription
  calling_party_name      = each.value.calling_name
  default_media_language  = "en-AU"
  groups                  = [for g in local.queue_groups[each.key] : var.group_ids[g]]
  wrapup_codes            = [for w in each.value.wrapup_codes : var.wrapup_code_ids[w]]

  media_settings_call {
    alerting_timeout_sec      = 20
    service_level_percentage  = each.value.sla_percent / 100
    service_level_duration_ms = each.value.sla_seconds * 1000
  }

  # Surge protection. If the estimated wait grows past a limit, add another group at once, without waiting
  # for the next ring. This is what you want on a Monday morning peak or after a big announcement.
  dynamic "conditional_group_routing_rules" {
    for_each = each.value.surge

    content {
      metric          = "EstimatedWaitTime"
      operator        = "GreaterThanOrEqualTo"
      condition_value = conditional_group_routing_rules.value.estimated_wait_seconds
      wait_seconds    = 15

      groups {
        member_group_id   = var.group_ids[conditional_group_routing_rules.value.group]
        member_group_type = "GROUP"
      }
    }
  }

  dynamic "bullseye_rings" {
    for_each = local.rings[each.key]

    content {
      expansion_timeout_seconds = bullseye_rings.value.wait

      dynamic "member_groups" {
        for_each = bullseye_rings.value.group == null ? [] : [bullseye_rings.value.group]

        content {
          member_group_id   = var.group_ids[member_groups.value]
          member_group_type = "GROUP"
        }
      }
    }
  }
}
