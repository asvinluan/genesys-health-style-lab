#!/usr/bin/env bash
# Step 2. Downloads the Genesys provider and checks the files are well-formed. Changes nothing in Genesys.
source "$(dirname "$0")/lib.sh"
pick_tf
cd "$TF_DIR"

say "Formatting check"
$TF fmt -check -recursive || die "Files are not formatted. Run: $TF fmt -recursive"
ok "Formatting is clean"

say "Initialising (no remote state)"
$TF init -backend=false -input=false
say "Validating"
$TF validate
ok "Configuration is valid"
