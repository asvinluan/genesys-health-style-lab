#!/usr/bin/env bash
# Step 4. Builds it. Applies ONLY the plan you already read, so nothing changes between plan and apply.
# Usage: ./04-apply.sh [minimal|full|hardened]
source "$(dirname "$0")/lib.sh"
pick_tf; require_credentials
ENV="${1:-full}"
PLAN="$TF_DIR/plan-${ENV}.tfplan"
[ -f "$PLAN" ] || die "No saved plan. Run ./03-plan.sh ${ENV} first."

cd "$TF_DIR"
warn "This will create objects in Genesys org region ${GENESYSCLOUD_REGION:-ap-southeast-2}."
read -r -p "Type YES to continue: " answer
[ "$answer" = "YES" ] || die "Cancelled. Nothing was changed."
$TF apply -input=false "plan-${ENV}.tfplan"
rm -f "plan-${ENV}.tfplan"
ok "Built. Next: ./05-inventory.sh, then the test calls in docs/BUILD-MANUAL.md."
