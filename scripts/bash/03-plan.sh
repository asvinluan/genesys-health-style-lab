#!/usr/bin/env bash
# Step 3. Shows what WOULD be built. Changes nothing. Always read the summary line.
# Usage: ./03-plan.sh [minimal|full|hardened]     (default: full)
source "$(dirname "$0")/lib.sh"
pick_tf; require_credentials
ENV="${1:-full}"
[ -f "$TF_DIR/envs/${ENV}.tfvars" ] || die "No such environment: ${ENV}. Use minimal, full or hardened."

# Build the function zip only if it is missing. A rebuilt zip has new timestamps, so a new hash,
# and the plan would show a function update every time. The built zip is committed to Git on purpose.
[ -f "$FUNCTION_DIR/dist/normalise-reference.zip" ] || "$(dirname "$0")/01-package-function.sh"
cd "$TF_DIR"
$TF init -input=false >/dev/null
say "Planning with envs/${ENV}.tfvars"
$TF plan -input=false -var-file="envs/${ENV}.tfvars" -out="plan-${ENV}.tfplan"
ok "Plan saved to terraform/plan-${ENV}.tfplan. Read the 'Plan: X to add' line before you apply."
