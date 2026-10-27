#!/usr/bin/env bash
# Step 0. Checks tools, credentials and the connection. Changes nothing.
source "$(dirname "$0")/lib.sh"

say "Checking tools"
for t in curl jq node; do need "$t"; ok "$t found"; done
pick_tf; ok "$TF found: $($TF version | head -1)"

say "Checking credentials and connection"
get_token
ok "Token received for region ${GENESYSCLOUD_REGION}"
ORG="$(api_get /api/v2/organizations/me | jq -r '.name')"
ok "Connected to Genesys org: ${ORG}"
warn "Make sure this is your lab or dev org, not a customer org."
