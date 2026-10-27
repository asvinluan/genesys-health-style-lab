# Root module: wires the building blocks together in dependency order.
# foundation -> telephony -> routing -> architect -> integrations -> ai -> quality -> digital, plus security.
# The business design (queues, lines, roles, AI rules) is in locals.tf. The modules stay generic.

module "foundation" {
  source = "./modules/foundation"

  prefix                = var.prefix
  divisions             = local.divisions
  skills                = local.skills
  languages             = local.languages
  wrapup_codes          = local.wrapup_codes
  groups                = local.groups
  roles                 = local.roles
  group_roles           = local.group_roles
  integration_role_name = local.integration_role_name
  presence_label        = local.presence_label
}

module "security" {
  source = "./modules/security"

  enable       = var.enable_security_hardening
  ip_allowlist = var.signin_ip_allowlist
}

module "telephony" {
  source = "./modules/telephony"

  prefix           = var.prefix
  media_region     = var.media_region
  carrier_label    = "Lab SIP carrier"
  caller_name      = local.telephony.caller_name
  emergency_number = local.telephony.emergency_number
  site_caller_id   = local.telephony.site_caller_id
  did_range_start  = local.telephony.did_range_start
  did_range_end    = local.telephony.did_range_end
  address          = local.telephony.address
}

module "routing" {
  source = "./modules/routing"

  prefix          = var.prefix
  flows_dir       = "${path.module}/flows"
  division_ids    = module.foundation.division_ids
  group_ids       = module.foundation.group_ids
  wrapup_code_ids = module.foundation.wrapup_code_ids
  queues          = local.queues
  time_zone       = var.time_zone
  holidays        = local.holidays
  open_schedules  = local.open_schedules
  schedule_groups = local.schedule_groups
}

module "architect" {
  source = "./modules/architect"

  prefix               = var.prefix
  flows_dir            = "${path.module}/flows"
  division_name        = "Home"
  division_id          = module.foundation.home_division_id
  queue_names          = module.routing.queue_names
  schedule_group_ids   = module.routing.schedule_group_ids
  flows                = local.flows
  lines                = local.lines
  surge_flow           = local.surge_flow
  event_workflow       = local.event_workflow
  surge_mode_enabled   = var.surge_mode_enabled
  surge_notices        = local.surge_notices
  enable_event_trigger = var.enable_event_trigger

  depends_on = [module.telephony]
}

module "integrations" {
  source = "./modules/integrations"

  prefix                 = var.prefix
  integration_role_id    = module.foundation.integration_role_id
  home_division_id       = module.foundation.home_division_id
  function_zip_path      = "${path.module}/function-actions/normalise-reference/dist/normalise-reference.zip"
  enable_case_api        = var.enable_case_api
  case_api_base_url      = var.case_api_base_url
  case_api_token_url     = var.case_api_token_url
  case_api_client_id     = var.case_api_client_id
  case_api_client_secret = var.case_api_client_secret
  enable_eventbridge     = var.enable_eventbridge
  aws_account_id         = var.aws_account_id
  aws_region             = var.aws_region
}

module "ai" {
  count  = var.enable_ai ? 1 : 0
  source = "./modules/ai"

  prefix                        = var.prefix
  kb_name                       = local.ai.kb_name
  kb_category                   = local.ai.kb_category
  kb_tool_description           = local.ai.kb_tool_description
  agent_role                    = local.ai.agent_role
  agent_instructions            = local.ai.agent_instructions
  guardrails                    = local.ai.guardrails
  exit_message                  = local.ai.exit_message
  escalation_message            = local.ai.escalation_message
  guardrail_message             = local.ai.guardrail_message
  threshold_message             = local.ai.threshold_message
  guardrail_violation_threshold = var.guardrail_violation_threshold
  faq                           = local.ai.faq
  topics                        = local.ai.topics
}

module "quality" {
  count  = var.enable_quality ? 1 : 0
  source = "./modules/quality"

  prefix              = var.prefix
  home_division_id    = module.foundation.home_division_id
  time_zone           = var.time_zone
  archive_days        = var.recording_archive_days
  delete_days         = var.recording_delete_days
  queue_ids           = module.routing.queue_ids
  recorded_queue_keys = local.recorded_queue_keys
  evaluation_name     = local.evaluation_name
  evaluation_groups   = local.evaluation_groups
}

module "digital" {
  count  = var.enable_digital && var.enable_ai ? 1 : 0
  source = "./modules/digital"

  prefix            = var.prefix
  message_flow_id   = module.architect.flow_ids["message"]
  knowledge_base_id = module.ai[0].knowledge_base_id
  allowed_domains   = var.web_allowed_domains
  enable_sso        = var.enable_sso
  sso_issuer_uri    = var.sso_issuer_uri
  sso_target_uri    = var.sso_target_uri
  sso_certificate   = var.sso_certificate
}
