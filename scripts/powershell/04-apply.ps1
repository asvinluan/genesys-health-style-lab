# Step 4. Builds it. Applies ONLY the plan you already read, so nothing changes between plan and apply.
# Usage: .\04-apply.ps1 [-Environment minimal|full|hardened]
param([ValidateSet('minimal', 'full', 'hardened')][string]$Environment = 'full')
. "$PSScriptRoot\lib.ps1"
$tf = Get-TfCommand
Assert-Credentials

$plan = Join-Path $script:TfDir "plan-$Environment.tfplan"
if (-not (Test-Path $plan)) { Fail "No saved plan. Run .\03-plan.ps1 -Environment $Environment first." }

Warn "This will create objects in Genesys org region $env:GENESYSCLOUD_REGION."
$answer = Read-Host "Type YES to continue"
if ($answer -cne 'YES') { Fail "Cancelled. Nothing was changed." }

Push-Location $script:TfDir
try {
    & $tf apply -input=false "plan-$Environment.tfplan"
    Assert-LastExit 'apply'
    Remove-Item "plan-$Environment.tfplan" -Force
    Ok "Built. Next: .\05-inventory.ps1, then the test calls in docs\BUILD-MANUAL.md."
} finally { Pop-Location }
