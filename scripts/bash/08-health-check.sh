#!/usr/bin/env bash
# Step 8. Daily health check for the lab objects. READ-ONLY. Safe to run from a schedule.
# This is the L2 "is the platform healthy and is what we built still there?" check from the job description.
# Exit code 0 = all good, 1 = at least one FAIL. WARN does not fail the run.
#
# HONEST NOTE: written against the public Genesys Cloud API shapes and tested only against a local mock server,
# never a live org. If a field name differs in your org, the check will say so. Fix it and note it in the run log.
# It looks at the first 100 objects of each kind. That is enough for a lab; a big org needs paging.
source "$(dirname "$0")/lib.sh"
need curl; need jq
PREFIX="${PREFIX:-DH}"
EXPECT_QUEUES="${EXPECT_QUEUES:-9}"
EXPECT_LINES="${EXPECT_LINES:-4}"
EXPECT_FLOWS="${EXPECT_FLOWS:-10}"
FAILS=0

pass()  { ok "$*"; }
# expect_eq "label" actual expected
expect_eq() { if [ "$2" -eq "$3" ]; then pass "$2 $1 found"; else bad "$2 $1 found, expected $3"; fi; }
bad()   { printf '\033[1;31m FAIL \033[0m%s\n' "$*"; FAILS=$((FAILS + 1)); }

get_token
START=$(date +%s)

say "1. Can we sign in and reach the platform?"
ORG="$(api_get /api/v2/organizations/me | jq -r '.name // empty')" || ORG=""
SECS=$(( $(date +%s) - START ))
if [ -n "$ORG" ]; then pass "Connected to org: ${ORG} (${SECS}s including sign-in)"; else bad "Could not read the organisation"; fi

say "2. Queues (${PREFIX} prefix, expect ${EXPECT_QUEUES})"
Q="$(api_get '/api/v2/routing/queues?pageSize=100' | jq --arg p "${PREFIX} " '[.entities[]? | select(.name | startswith($p))]')"
N="$(printf '%s' "$Q" | jq 'length')"
expect_eq queues "$N" "$EXPECT_QUEUES"

say "3. Flows are published (${PREFIX} prefix, expect ${EXPECT_FLOWS})"
F="$(api_get '/api/v2/flows?pageSize=100' | jq --arg p "${PREFIX} " '[.entities[]? | select(.name | startswith($p))]')"
N="$(printf '%s' "$F" | jq 'length')"
expect_eq flows "$N" "$EXPECT_FLOWS"
UNPUB="$(printf '%s' "$F" | jq -r '.[] | select(.publishedVersion == null) | .name')"
if [ -n "$UNPUB" ]; then
  while read -r n; do bad "Flow not published: ${n}"; done <<<"$UNPUB"
else
  pass "Every flow has a published version"
fi

say "4. Number-to-flow configs (expect ${EXPECT_LINES})"
I="$(api_get '/api/v2/architect/ivrs?pageSize=100' | jq --arg p "${PREFIX} " '[.entities[]? | select(.name | startswith($p))]')"
N="$(printf '%s' "$I" | jq 'length')"
expect_eq "IVR configs" "$N" "$EXPECT_LINES"
EMPTY="$(printf '%s' "$I" | jq -r '.[] | select((.dnis // []) | length == 0) | .name')"
if [ -z "$EMPTY" ]; then
  pass "Every IVR config has a number"
else
  while read -r n; do warn "No number on: ${n}"; done <<<"$EMPTY"
fi

say "5. Surge switch"
E="$(api_get '/api/v2/architect/emergencygroups?pageSize=100' | jq --arg p "${PREFIX} " '[.entities[]? | select(.name | startswith($p))]')"
if [ "$(printf '%s' "$E" | jq 'length')" -eq 0 ]; then
  bad "No emergency group found"
elif [ "$(printf '%s' "$E" | jq '[.[] | select(.enabled == true)] | length')" -gt 0 ]; then
  warn "Surge switch is ON. Confirm this is intended and note when it was switched on."
else
  pass "Surge switch is off"
fi

say "Result"
if [ "$FAILS" -gt 0 ]; then
  printf '\033[1;31m %s check(s) failed.\033[0m Raise an incident. Do not fix by hand in the console: fix the code and re-apply.\n' "$FAILS"
  exit 1
fi
pass "All checks passed. Record the date and your name in the run log."
