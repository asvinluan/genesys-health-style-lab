# Step 7. Tears down everything this repo built, and only that. Asks first.
. "$PSScriptRoot\lib.ps1"
$tf = Get-TfCommand
Assert-Credentials

Push-Location $script:TfDir
try {
    & $tf init -input=false | Out-Null
    Assert-LastExit 'init'
    Say "Showing what will be deleted"
    & $tf plan -destroy -input=false "-var-file=envs/full.tfvars" | Select-Object -Last 25
    Warn "This deletes the queues, flows, forms, knowledge base and recordings policy that this repo made."
    Warn "Recordings already stored follow Genesys retention rules, not this command."
    $answer = Read-Host "Type the word DESTROY to continue"
    if ($answer -cne 'DESTROY') { Fail "Cancelled. Nothing was changed." }
    & $tf destroy -input=false -auto-approve "-var-file=envs/full.tfvars"
    Assert-LastExit 'destroy'
    Ok "Destroyed. Run .\05-inventory.ps1 to confirm nothing with the DH prefix is left."
} finally { Pop-Location }
