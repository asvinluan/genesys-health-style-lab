#!/usr/bin/env bash
# Step 5. The Genesys version of the AWS cost-guard. Read-only.
# Genesys is billed by licence and usage under your contract, not by the hour, so there is no "meter" to stop.
# What you CAN check is how many lab objects exist, and whether anything is left after a destroy.
source "$(dirname "$0")/lib.sh"
need curl; need jq
get_token
PREFIX="${PREFIX:-DH}"

count() {  # count "Label" "/api/path?query"
  local n; n="$(api_get "$2" | jq -r '.total // (.entities | length) // 0')"
  printf '  %-34s %s\n' "$1" "$n"
}

say "Objects in the org (all, not only lab)"
count "Queues"                 "/api/v2/routing/queues?pageSize=1"
count "Architect flows"        "/api/v2/flows?pageSize=1"
count "IVR configs"            "/api/v2/architect/ivrs?pageSize=1"
count "Schedules"              "/api/v2/architect/schedules?pageSize=1"
count "Schedule groups"        "/api/v2/architect/schedulegroups?pageSize=1"
count "Skills"                 "/api/v2/routing/skills?pageSize=1"
count "Groups"                 "/api/v2/groups?pageSize=1"
count "Roles"                  "/api/v2/authorization/roles?pageSize=1"
count "Knowledge bases"         "/api/v2/knowledge/knowledgebases?pageSize=1"
count "Integrations"           "/api/v2/integrations?pageSize=1"

say "Queues with the ${PREFIX} prefix (lab objects)"
api_get "/api/v2/routing/queues?pageSize=100&name=${PREFIX}*" | jq -r '.entities[]?.name' | sed 's/^/  /' || true

say "Reminder"
echo "  - Check usage and charges in Genesys Admin > Billing, and in your contract."
echo "  - A leftover phone number or add-on licence is where lab cost hides, not the queues."
