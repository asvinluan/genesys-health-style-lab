# Step 0. Checks tools, credentials and the connection. Changes nothing.
. "$PSScriptRoot\lib.ps1"

Say "Checking tools"
foreach ($t in 'node') { Assert-Tool $t; Ok "$t found" }
$tf = Get-TfCommand
Ok "IaC tool found: $tf"

Say "Checking credentials and connection"
Get-GenesysToken
Ok "Token received for region $env:GENESYSCLOUD_REGION"
$org = Invoke-GenesysGet '/api/v2/organizations/me'
Ok "Connected to Genesys org: $($org.name)"
Warn "Make sure this is your lab or dev org, not a customer org."
