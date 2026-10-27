# Integrations: how flows, agents and the AI reach other systems, and how other systems reach Genesys.
# AWS Connect lab equivalent: Lambda functions, Secrets Manager, EventBridge, API Gateway credentials.
#
# Genesys has four kinds of data action. Pick the lightest that works:
#   1. Genesys Cloud data action   : call Genesys's own API (read a queue, a user).
#   2. Web services data action    : call YOUR REST API directly from Genesys. No code to host.
#   3. Function data action        : a small Node.js function Genesys runs for you (the Lambda replacement).
#   4. AWS Lambda data action      : call a Lambda in YOUR AWS account. Use when the code needs your VPC or your IAM.

# ------------------------------------------------------------ 1. Genesys Cloud data action
resource "genesyscloud_oauth_client" "data_actions" {
  name                          = "${var.prefix} Data Actions"
  description                   = "Client the data actions use to call the Genesys API. Least-privilege role, home division only."
  authorized_grant_type         = "CLIENT-CREDENTIALS"
  access_token_validity_seconds = 3600
  state                         = "active"

  roles {
    role_id     = var.integration_role_id
    division_id = var.home_division_id
  }

  # Creates a stored credential from this client. The secret never has to appear in a file.
  integration_credential_name = "${var.prefix} Data Actions Credential"
}

resource "genesyscloud_integration" "genesys_data_actions" {
  integration_type = "purecloud-data-actions"
  intended_state   = "ENABLED"

  config {
    name = "${var.prefix} Genesys Data Actions"
    credentials = {
      pureCloudOAuthClient = genesyscloud_oauth_client.data_actions.integration_credential_id
    }
    properties = jsonencode({})
    advanced   = jsonencode({})
  }
}

resource "genesyscloud_integration_action" "queue_lookup" {
  name                   = "${var.prefix} Get Queue"
  category               = "Genesys Cloud Data Action"
  integration_id         = genesyscloud_integration.genesys_data_actions.id
  secure                 = false
  config_timeout_seconds = 10

  contract_input = jsonencode({
    "type"     = "object"
    "required" = ["queueId"]
    "properties" = {
      "queueId" = { "type" = "string" }
    }
  })

  contract_output = jsonencode({
    "type"     = "object"
    "required" = ["name"]
    "properties" = {
      "name"        = { "type" = "string" }
      "memberCount" = { "type" = "integer" }
    }
  })

  config_request {
    request_url_template = "/api/v2/routing/queues/$${input.queueId}"
    request_type         = "GET"
    request_template     = "$${input.rawRequest}"
  }

  config_response {
    translation_map = {
      name        = "$.name"
      memberCount = "$.memberCount"
    }
    translation_map_defaults = {
      memberCount = "0"
    }
    success_template = "{ \"name\": $${name}, \"memberCount\": $${memberCount} }"
  }
}

# ------------------------------------------------------------ 3. Function data action
resource "genesyscloud_integration" "functions" {
  integration_type = "function-data-actions"
  intended_state   = "ENABLED"

  config {
    name       = "${var.prefix} Functions"
    properties = jsonencode({})
    advanced   = jsonencode({})
  }
}

resource "genesyscloud_integration_action" "normalise_reference" {
  name                   = "${var.prefix} Normalise Reference"
  category               = "Function Data Actions"
  integration_id         = genesyscloud_integration.functions.id
  secure                 = false
  config_timeout_seconds = 10

  contract_input = jsonencode({
    "type"     = "object"
    "required" = ["spoken"]
    "properties" = {
      "spoken" = {
        "type"        = "string"
        "description" = "What the caller said or typed, for example: K I two zero two six zero zero zero one two three"
      }
    }
  })

  contract_output = jsonencode({
    "type"     = "object"
    "required" = ["valid", "reference"]
    "properties" = {
      "valid"     = { "type" = "boolean" }
      "reference" = { "type" = "string" }
      "reason"    = { "type" = "string" }
    }
  })

  config_request {
    request_type         = "POST"
    request_url_template = ""
    request_template     = "$${input.rawRequest}"
  }

  function_config {
    description       = "Normalise a spoken or typed reference number to the standard reference format"
    handler           = "index.handler"
    runtime           = "nodejs22.x"
    timeout_seconds   = 5
    file_path         = var.function_zip_path
    file_content_hash = filesha256(var.function_zip_path)
  }
}

# ------------------------------------------------------------ 2. Web services data action (gated)
resource "genesyscloud_integration_credential" "case_api" {
  count                = var.enable_case_api ? 1 : 0
  name                 = "${var.prefix} Case API OAuth"
  credential_type_name = "userDefinedOAuth"

  fields = {
    clientId     = var.case_api_client_id
    clientSecret = var.case_api_client_secret
    loginUrl     = var.case_api_token_url
  }
}

resource "genesyscloud_integration" "case_api" {
  count            = var.enable_case_api ? 1 : 0
  integration_type = "custom-rest-actions"
  intended_state   = "ENABLED"

  config {
    name = "${var.prefix} Case API"
    credentials = {
      userDefinedOAuth = genesyscloud_integration_credential.case_api[0].id
    }
    properties = jsonencode({})
    advanced   = jsonencode({})
  }
}

resource "genesyscloud_integration_action" "case_status" {
  count                  = var.enable_case_api ? 1 : 0
  name                   = "${var.prefix} Get Case Status"
  category               = "${var.prefix} Case API"
  integration_id         = genesyscloud_integration.case_api[0].id
  secure                 = true
  config_timeout_seconds = 8

  contract_input = jsonencode({
    "type"     = "object"
    "required" = ["reference"]
    "properties" = {
      "reference" = { "type" = "string" }
    }
  })

  contract_output = jsonencode({
    "type"     = "object"
    "required" = ["status"]
    "properties" = {
      "status"      = { "type" = "string" }
      "nextStep"    = { "type" = "string" }
      "lastUpdated" = { "type" = "string" }
    }
  })

  config_request {
    request_url_template = "${var.case_api_base_url}/cases/$${input.reference}"
    request_type         = "GET"
    request_template     = "$${input.rawRequest}"
    headers = {
      Accept = "application/json"
    }
  }

  config_response {
    translation_map = {
      status      = "$.status"
      nextStep    = "$.nextStep"
      lastUpdated = "$.lastUpdated"
    }
    translation_map_defaults = {
      nextStep    = ""
      lastUpdated = ""
    }
    success_template = "{ \"status\": $${status}, \"nextStep\": $${nextStep}, \"lastUpdated\": $${lastUpdated} }"
  }
}

# ------------------------------------------------------------ events out to AWS (gated)
# AWS Connect lab equivalent: Kinesis, Firehose, S3 and Athena for reporting. Genesys already holds analytics,
# so the streaming path is only for feeding your own data lake. EventBridge is the supported door into AWS.
resource "genesyscloud_integration" "eventbridge" {
  count            = var.enable_eventbridge ? 1 : 0
  integration_type = "amazon-eventbridge-source"
  intended_state   = "ENABLED"

  config {
    name = "${var.prefix} EventBridge"
    properties = jsonencode({
      "awsAccountId"     = var.aws_account_id
      "awsAccountRegion" = var.aws_region
    })
    advanced = jsonencode({})
  }
}
