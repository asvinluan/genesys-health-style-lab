#!/usr/bin/env bash
# Step 7. Tears down everything this repo built, and only that. Asks twice.
source "$(dirname "$0")/lib.sh"
pick_tf; require_credentials
cd "$TF_DIR"
$TF init -input=false >/dev/null
say "Showing what will be deleted"
$TF plan -destroy -input=false -var-file="envs/full.tfvars" | tail -25
warn "This deletes the queues, flows, forms, knowledge base and recordings policy that this repo made."
warn "Recordings already stored follow Genesys retention rules, not this command."
read -r -p "Type the word DESTROY to continue: " answer
[ "$answer" = "DESTROY" ] || die "Cancelled. Nothing was changed."
$TF destroy -input=false -auto-approve -var-file="envs/full.tfvars"
ok "Destroyed. Run ./05-inventory.sh to confirm nothing with the DH prefix is left."
