# Step 6. Reverse direction. Reads what exists in the org and writes it as Terraform (CX as Code export).
# Use this to start from an existing org or to detect drift by hand. Read-only against Genesys.
param([string]$OutDir = '')
. "$PSScriptRoot\lib.ps1"
$tf = Get-TfCommand
Assert-Credentials
if (-not $OutDir) { $OutDir = Join-Path $script:RepoRoot 'export' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$config = @'
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
  directory                    = "./generated"
  resource_types               = ["genesyscloud_routing_queue", "genesyscloud_flow", "genesyscloud_architect_ivr"]
  include_state_file           = false
  export_as_hcl                = true
  log_permission_errors        = true
  enable_dependency_resolution = false
}
'@
Set-Content -Path (Join-Path $OutDir 'main.tf') -Value $config -Encoding UTF8

Push-Location $OutDir
try {
    & $tf init -input=false
    Assert-LastExit 'init'
    & $tf apply -input=false -auto-approve
    Assert-LastExit 'apply'
    Ok "Exported to $OutDir\generated. Review it, do not commit it blindly: it may contain real IDs."
} finally { Pop-Location }
