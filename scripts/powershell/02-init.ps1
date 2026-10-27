# Step 2. Downloads the Genesys provider and checks the files are well-formed. Changes nothing in Genesys.
. "$PSScriptRoot\lib.ps1"
$tf = Get-TfCommand
Push-Location $script:TfDir
try {
    Say "Formatting check"
    & $tf fmt -check -recursive
    if ($LASTEXITCODE -ne 0) { Fail "Files are not formatted. Run: $tf fmt -recursive" }
    Ok "Formatting is clean"

    Say "Initialising (no remote state)"
    & $tf init -backend=false -input=false
    Assert-LastExit 'init'
    Say "Validating"
    & $tf validate
    Assert-LastExit 'validate'
    Ok "Configuration is valid"
} finally { Pop-Location }
