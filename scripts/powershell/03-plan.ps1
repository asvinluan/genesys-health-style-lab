# Step 3. Shows what WOULD be built. Changes nothing. Always read the summary line.
# Usage: .\03-plan.ps1 [-Environment minimal|full|hardened]     (default: full)
param([ValidateSet('minimal', 'full', 'hardened')][string]$Environment = 'full')
. "$PSScriptRoot\lib.ps1"
$tf = Get-TfCommand
Assert-Credentials

# Build the function zip only if it is missing. A rebuilt zip has new timestamps, so a new hash,
# and the plan would show a function update every time. The built zip is committed to Git on purpose.
if (-not (Test-Path (Join-Path $script:FunctionDir 'dist\normalise-reference.zip'))) { & "$PSScriptRoot\01-package-function.ps1" }

Push-Location $script:TfDir
try {
    & $tf init -input=false | Out-Null
    Assert-LastExit 'init'
    Say "Planning with envs\$Environment.tfvars"
    & $tf plan -input=false "-var-file=envs/$Environment.tfvars" "-out=plan-$Environment.tfplan"
    Assert-LastExit 'plan'
    Ok "Plan saved to terraform\plan-$Environment.tfplan. Read the 'Plan: X to add' line before you apply."
} finally { Pop-Location }
