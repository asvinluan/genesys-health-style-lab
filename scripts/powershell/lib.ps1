# Shared helpers. Every other script starts with:  . "$PSScriptRoot\lib.ps1"
# Not run on its own. Works in Windows PowerShell 5.1 and PowerShell 7.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:RepoRoot    = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script:TfDir       = Join-Path $script:RepoRoot 'terraform'
$script:FunctionDir = Join-Path $script:TfDir 'function-actions\normalise-reference'

function Say  { param([string]$Text) Write-Host ""; Write-Host "==> $Text" -ForegroundColor Cyan }
function Ok   { param([string]$Text) Write-Host "  OK   $Text" -ForegroundColor Green }
function Warn { param([string]$Text) Write-Host " WARN  $Text" -ForegroundColor Yellow }
function Fail { param([string]$Text) Write-Host " FAIL  $Text" -ForegroundColor Red; exit 1 }

# Stops the script if the last native command (tofu, node) failed. PowerShell does not do this by itself.
function Assert-LastExit {
    param([string]$What)
    if ($LASTEXITCODE -ne 0) { Fail "$What failed (exit code $LASTEXITCODE)." }
}

# Use OpenTofu if it is installed, otherwise Terraform.
function Get-TfCommand {
    foreach ($name in 'tofu', 'terraform') {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    Fail "Neither tofu nor terraform is installed. See docs\RUNBOOK-POWERSHELL.md step 1."
}

# The Genesys domain for each region. Sydney is the default for this lab.
function Get-GenesysDomain {
    $region = $env:GENESYSCLOUD_REGION
    if (-not $region) { $region = 'ap-southeast-2' }
    switch ($region) {
        'ap-southeast-2' { return 'mypurecloud.com.au' }
        'ap-southeast-1' { return 'apse1.pure.cloud' }
        'ap-northeast-1' { return 'mypurecloud.jp' }
        'us-east-1'      { return 'mypurecloud.com' }
        'eu-west-1'      { return 'mypurecloud.ie' }
        'eu-central-1'   { return 'mypurecloud.de' }
        default          { Fail "Region '$region' is not in lib.ps1. Add it to Get-GenesysDomain." }
    }
}

# Stops with a plain message if the secrets are not set. Never prints the secret.
function Assert-Credentials {
    if (-not $env:GENESYSCLOUD_OAUTHCLIENT_ID)     { Fail "Set GENESYSCLOUD_OAUTHCLIENT_ID. See docs\RUNBOOK-POWERSHELL.md step 3." }
    if (-not $env:GENESYSCLOUD_OAUTHCLIENT_SECRET) { Fail "Set GENESYSCLOUD_OAUTHCLIENT_SECRET. See docs\RUNBOOK-POWERSHELL.md step 3." }
    if (-not $env:GENESYSCLOUD_REGION)             { $env:GENESYSCLOUD_REGION = 'ap-southeast-2' }
}

# GENESYS_LOGIN_BASE and GENESYS_API_BASE exist only so the scripts can be tested against a local mock server.
# Leave them unset in real use.
# Gets a short-lived access token (client-credentials grant). Kept in memory only.
function Get-GenesysToken {
    Assert-Credentials
    $domain = Get-GenesysDomain
    $pair   = '{0}:{1}' -f $env:GENESYSCLOUD_OAUTHCLIENT_ID, $env:GENESYSCLOUD_OAUTHCLIENT_SECRET
    $basic  = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pair))
    try {
        $r = Invoke-RestMethod -Method Post -Uri "$(if ($env:GENESYS_LOGIN_BASE) { $env:GENESYS_LOGIN_BASE } else { "https://login.$domain" })/oauth/token" `
            -Headers @{ Authorization = "Basic $basic" } `
            -ContentType 'application/x-www-form-urlencoded' `
            -Body 'grant_type=client_credentials'
    } catch {
        Fail "Could not get a token. Check the client ID, secret and region."
    }
    if (-not $r.access_token) { Fail "Could not get a token. Check the client ID, secret and region." }
    $script:Token = $r.access_token
}

# Invoke-GenesysGet '/api/v2/routing/queues?pageSize=1'
function Invoke-GenesysGet {
    param([string]$Path)
    $domain = Get-GenesysDomain
    Invoke-RestMethod -Method Get -Uri "$(if ($env:GENESYS_API_BASE) { $env:GENESYS_API_BASE } else { "https://api.$domain" })$Path" -Headers @{ Authorization = "Bearer $($script:Token)" }
}

function Assert-Tool {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Fail "'$Name' is not installed. See docs\RUNBOOK-POWERSHELL.md step 1."
    }
}
