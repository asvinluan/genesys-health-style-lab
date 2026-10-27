# Step 1. Tests the claim-number function, then zips it. Changes only the dist folder.
. "$PSScriptRoot\lib.ps1"
Assert-Tool 'node'

Say "Running the function tests"
Push-Location $script:FunctionDir
try {
    & node --test
    Assert-LastExit 'The function tests'
} finally { Pop-Location }
Ok "Tests passed"

Say "Building the zip"
$dist = Join-Path $script:FunctionDir 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$zip = Join-Path $dist 'normalise-reference.zip'
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $script:FunctionDir 'index.js') -DestinationPath $zip
Ok "Built $zip"
