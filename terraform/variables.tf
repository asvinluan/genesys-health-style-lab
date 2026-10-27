variable "prefix" {
  description = "Short prefix on every object name. Makes lab objects easy to find and clean up."
  type        = string
  default     = "DH"
}

variable "time_zone" {
  type    = string
  default = "Australia/Melbourne"
}

variable "media_region" {
  description = "Where voice media is handled. Sydney."
  type        = string
  default     = "ap-southeast-2"
}

variable "enable_ai" {
  description = "Build the knowledge base, virtual agent with guardrails, and speech analytics."
  type        = bool
  default     = true
}

variable "enable_quality" {
  description = "Build evaluation and survey forms, recording retention and the WFM business unit."
  type        = bool
  default     = true
}

variable "enable_digital" {
  description = "Build web messaging. Needs enable_ai (the chat panel reads the knowledge base)."
  type        = bool
  default     = true
}

variable "surge_mode_enabled" {
  description = "Surge switch. Flip to true during a surge or major event and apply."
  type        = bool
  default     = false
}

variable "guardrail_violation_threshold" {
  type    = number
  default = 3
}

variable "recording_archive_days" {
  type    = number
  default = 90
}

variable "recording_delete_days" {
  type    = number
  default = 2555
}

variable "web_allowed_domains" {
  description = "Websites allowed to load the chat widget."
  type        = list(string)
  default     = ["www.health-style-lab.example.invalid"]
}

# Optional pieces. Each one needs something real, so each is off by default.
variable "enable_case_api" {
  type    = bool
  default = false
}

variable "case_api_base_url" {
  type    = string
  default = "https://case-api.example.invalid"
}

variable "case_api_token_url" {
  type    = string
  default = "https://login.example.invalid/oauth2/token"
}

variable "case_api_client_id" {
  type      = string
  default   = ""
  sensitive = true
}

variable "case_api_client_secret" {
  type      = string
  default   = ""
  sensitive = true
}

variable "enable_eventbridge" {
  type    = bool
  default = false
}

variable "aws_account_id" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "enable_event_trigger" {
  type    = bool
  default = false
}

variable "enable_sso" {
  type    = bool
  default = false
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
  type    = string
  default = ""
}

variable "enable_security_hardening" {
  description = "Apply organisation-wide sign-in hardening (MFA, idle timeout, password rules). Changes how every user signs in. Lab only."
  type        = bool
  default     = false
}

variable "signin_ip_allowlist" {
  description = "Networks users may sign in from (CIDR). Empty means no restriction. A wrong list locks everyone out."
  type        = list(string)
  default     = []
}
