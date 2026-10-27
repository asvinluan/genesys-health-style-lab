# Credentials are NEVER in this file. Set three environment variables before you run anything:
#   GENESYSCLOUD_OAUTHCLIENT_ID
#   GENESYSCLOUD_OAUTHCLIENT_SECRET
#   GENESYSCLOUD_REGION   (ap-southeast-2 for Sydney)
# AWS Connect lab equivalent: the AWS provider reading AWS_PROFILE or OIDC role credentials.
provider "genesyscloud" {
  sdk_debug = false
}
