#!/usr/bin/env bash
# Step 6. Reverse direction. Reads what exists in the org and writes it as Terraform (CX as Code export).
# Use this to start from an existing org or to detect drift by hand. Read-only against Genesys.
source "$(dirname "$0")/lib.sh"
pick_tf; require_credentials
OUT="${1:-$REPO_ROOT/export}"
mkdir -p "$OUT"
cat > "$OUT/main.tf" <<'TFEOF'
terraform {
  required_providers {
    genesyscloud = {
      source  = "mypurecloud/genesyscloud"
      version = "~> 1.87"
    }
  }
}
provider "genesyscloud" {}
resource "genesyscloud_tf_export" "export" {
  directory                      = "./generated"
  resource_types                 = ["genesyscloud_routing_queue", "genesyscloud_flow", "genesyscloud_architect_ivr"]
  include_state_file             = false
  export_as_hcl                  = true
  log_permission_errors          = true
  enable_dependency_resolution   = false
}
TFEOF
cd "$OUT"
$TF init -input=false
$TF apply -input=false -auto-approve
ok "Exported to $OUT/generated. Review it, do not commit it blindly: it may contain real IDs."
