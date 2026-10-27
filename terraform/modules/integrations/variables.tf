variable "prefix" {
  type = string
}

variable "integration_role_id" {
  description = "Role given to the data-action OAuth client (least privilege, from the foundation module)."
  type        = string
}

variable "home_division_id" {
  type = string
}

variable "function_zip_path" {
  description = "Path to the built function zip. Genesys cannot download an uploaded zip, so keep the source in Git."
  type        = string
}

variable "enable_case_api" {
  description = "Create the web-services data action that calls the agency's case API. Off by default: it needs a real endpoint and credentials."
  type        = bool
  default     = false
}

variable "case_api_base_url" {
  type    = string
  default = "https://case-api.example.invalid"
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

variable "case_api_token_url" {
  type    = string
  default = "https://login.example.invalid/oauth2/token"
}

variable "enable_eventbridge" {
  description = "Stream Genesys events to Amazon EventBridge in your AWS account. Off by default."
  type        = bool
  default     = false
}

variable "aws_account_id" {
  description = "AWS account that receives the events. Never commit a real account ID."
  type        = string
  default     = ""
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}
