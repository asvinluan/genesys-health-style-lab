variable "prefix" {
  type = string
}

variable "message_flow_id" {
  description = "Inbound short message flow, from the architect module."
  type        = string
}

variable "knowledge_base_id" {
  description = "Knowledge base that the web chat help panel can search."
  type        = string
}

variable "allowed_domains" {
  description = "Websites allowed to load the chat widget. Genesys rejects any other site. Never use allow_all_domains in production."
  type        = list(string)
}

variable "enable_sso" {
  description = "Create a SAML single sign-on provider. Needs a real identity-provider certificate, so off by default."
  type        = bool
  default     = false
}

variable "sso_issuer_uri" {
  type    = string
  default = ""
}

variable "sso_target_uri" {
  type    = string
  default = ""
}

variable "sso_certificate" {
  description = "Base64 public certificate from your identity provider. A public cert, not a secret, but still not committed in this lab."
  type        = string
  default     = ""
}
