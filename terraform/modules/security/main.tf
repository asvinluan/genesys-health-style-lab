# Organisation security settings.
# AWS Connect lab equivalents: IAM account password policy, SCP guard rails, IAM Identity Center session policy.
#
# WARNING. This resource changes sign-in rules for every person in the org.
#  - multifactor_authentication_required: users must have MFA, or they cannot sign in.
#  - ip_address_allowlist: users outside the list cannot sign in. A typo locks everyone out, including you.
# It does not affect the OAuth client that Terraform uses (that is a machine credential, with its own IP allow-list
# set on the client in the OAuth screen).
# It is off by default. Use it first in a lab org you can recover, and keep a recovery contact with Genesys.

resource "genesyscloud_organization_authentication_settings" "this" {
  count = var.enable ? 1 : 0

  multifactor_authentication_required = var.mfa_required
  universal_logout                    = true
  ip_address_allowlist                = var.ip_allowlist

  password_requirements {
    minimum_length   = var.password_min_length
    minimum_digits   = 1
    minimum_upper    = 1
    minimum_lower    = 1
    minimum_specials = 1
    expiration_days  = var.password_expiration_days
  }

  timeout_settings {
    enable_idle_token_timeout  = true
    idle_token_timeout_seconds = var.idle_timeout_seconds
  }
}
