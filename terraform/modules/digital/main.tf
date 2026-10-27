# Digital channels and single sign-on.
# AWS Connect lab equivalents:
#   Connect chat widget + API Gateway + WAF/CORS   -> web messaging deployment with allowed domains
#   IAM Identity Center (SAML)                      -> Genesys SSO with a generic SAML provider

resource "genesyscloud_webdeployments_configuration" "chat" {
  name             = "${var.prefix} Web Messaging"
  description      = "Website chat"
  default_language = "en-us"
  languages        = ["en-us"]

  messenger {
    enabled = true

    apps {
      conversations {
        enabled                     = true
        show_agent_typing_indicator = true
        show_user_typing_indicator  = true
        markdown_enabled            = true
      }

      knowledge {
        enabled           = true
        knowledge_base_id = var.knowledge_base_id
      }
    }

    styles {
      primary_color = "#0B3C5D"
    }
  }
}

resource "genesyscloud_webdeployments_deployment" "chat" {
  name            = "${var.prefix} Website Chat"
  description     = "Only the listed domains can load the widget"
  allowed_domains = var.allowed_domains
  flow_id         = var.message_flow_id

  configuration {
    id      = genesyscloud_webdeployments_configuration.chat.id
    version = genesyscloud_webdeployments_configuration.chat.version
  }
}

resource "genesyscloud_idp_generic" "sso" {
  count = var.enable_sso ? 1 : 0

  name                   = "${var.prefix} SSO"
  issuer_uri             = var.sso_issuer_uri
  target_uri             = var.sso_target_uri
  certificates           = [var.sso_certificate]
  sign_authn_requests    = true
  name_identifier_format = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
}
