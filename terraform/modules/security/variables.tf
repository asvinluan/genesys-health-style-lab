variable "enable" {
  description = "Apply organisation-wide sign-in hardening. This changes how EVERY user signs in to the org. Lab orgs only, and read the lockout note first."
  type        = bool
  default     = false
}

variable "mfa_required" {
  type    = bool
  default = true
}

variable "idle_timeout_seconds" {
  description = "Sign out an idle session after this many seconds."
  type        = number
  default     = 900
}

variable "ip_allowlist" {
  description = "Networks users may sign in from, in CIDR form. EMPTY means no restriction. A wrong list locks everyone out, including you."
  type        = list(string)
  default     = []
}

variable "password_min_length" {
  type    = number
  default = 14
}

variable "password_expiration_days" {
  description = "0 means passwords do not expire. Current government guidance favours length and MFA over forced expiry. Confirm your agency's policy."
  type        = number
  default     = 0
}
