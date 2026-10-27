#!/usr/bin/env bash
# Step 1. Tests the claim-number function, then zips it. Changes only the dist folder.
source "$(dirname "$0")/lib.sh"
need node

say "Running the function tests"
( cd "$FUNCTION_DIR" && node --test )
ok "Tests passed"

say "Building the zip"
mkdir -p "$FUNCTION_DIR/dist"
rm -f "$FUNCTION_DIR/dist/normalise-reference.zip"
if command -v zip >/dev/null 2>&1; then
  ( cd "$FUNCTION_DIR" && zip -q -X dist/normalise-reference.zip index.js )
elif command -v python3 >/dev/null 2>&1; then
  ( cd "$FUNCTION_DIR" && python3 -m zipfile -c dist/normalise-reference.zip index.js )
else
  die "Neither zip nor python3 is installed. Install one of them."
fi
ok "Built $FUNCTION_DIR/dist/normalise-reference.zip"
