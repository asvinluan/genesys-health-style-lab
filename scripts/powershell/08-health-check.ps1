# Step 8. Daily health check for the lab objects. READ-ONLY. Safe to run from a schedule.
# This is the L2 "is the platform healthy and is what we built still there?" check from the job description.
# Exit code 0 = all good, 1 = at least one FAIL. WARN does not fail the run.
#
# HONEST NOTE: written against the public Genesys Cloud API shapes and tested only against a local mock server,
# never a live org. If a field name differs in your org, the check will say so. Fix it and note it in the run log.
# It looks at the first 100 objects of each kind. That is enough for a lab; a big org needs paging.
param(
    [string]$Prefix = 'DH',
    [int]$ExpectQueues = 9,
    [int]$ExpectLines = 4,
    [int]$ExpectFlows = 10
)
. "$PSScriptRoot\lib.ps1"
$script:Fails = 0
function Bad { param([string]$Text) Write-Host " FAIL  $Text" -ForegroundColor Red; $script:Fails++ }

Get-GenesysToken
$start = Get-Date

# Strict mode is on, so a missing property is an error. This returns $null instead.
function Prop { param($Obj, [string]$Name) $p = $Obj.PSObject.Properties[$Name]; if ($p) { $p.Value } else { $null } }

function Get-Mine {
    param([string]$Path)
    $r = Invoke-GenesysGet $Path
    @($r.entities) | Where-Object { $_ -and $_.name -like "$Prefix *" }
}

Say "1. Can we sign in and reach the platform?"
$org = Invoke-GenesysGet '/api/v2/organizations/me'
$secs = [int]((Get-Date) - $start).TotalSeconds
if ($org.name) { Ok "Connected to org: $($org.name) (${secs}s including sign-in)" } else { Bad 'Could not read the organisation' }

Say "2. Queues ($Prefix prefix, expect $ExpectQueues)"
$q = @(Get-Mine '/api/v2/routing/queues?pageSize=100')
if ($q.Count -eq $ExpectQueues) { Ok "$($q.Count) queues found" } else { Bad "$($q.Count) queues found, expected $ExpectQueues" }

Say "3. Flows are published ($Prefix prefix, expect $ExpectFlows)"
$f = @(Get-Mine '/api/v2/flows?pageSize=100')
if ($f.Count -eq $ExpectFlows) { Ok "$($f.Count) flows found" } else { Bad "$($f.Count) flows found, expected $ExpectFlows" }
$unpub = @($f | Where-Object { -not (Prop $_ 'publishedVersion') })
if ($unpub.Count -gt 0) { foreach ($u in $unpub) { Bad "Flow not published: $($u.name)" } } else { Ok 'Every flow has a published version' }

Say "4. Number-to-flow configs (expect $ExpectLines)"
$i = @(Get-Mine '/api/v2/architect/ivrs?pageSize=100')
if ($i.Count -eq $ExpectLines) { Ok "$($i.Count) IVR configs found" } else { Bad "$($i.Count) IVR configs found, expected $ExpectLines" }
$empty = @($i | Where-Object { -not (Prop $_ 'dnis') -or @(Prop $_ 'dnis').Count -eq 0 })
if ($empty.Count -gt 0) { foreach ($e in $empty) { Warn "No number on: $($e.name)" } } else { Ok 'Every IVR config has a number' }

Say "5. Surge switch"
$e = @(Get-Mine '/api/v2/architect/emergencygroups?pageSize=100')
if ($e.Count -eq 0) { Bad 'No emergency group found' }
elseif (@($e | Where-Object { (Prop $_ 'enabled') -eq $true }).Count -gt 0) { Warn 'Surge switch is ON. Confirm this is intended and note when it was switched on.' }
else { Ok 'Surge switch is off' }

Say 'Result'
if ($script:Fails -gt 0) {
    Write-Host " $($script:Fails) check(s) failed. Raise an incident. Do not fix by hand in the console: fix the code and re-apply." -ForegroundColor Red
    exit 1
}
Ok 'All checks passed. Record the date and your name in the run log.'
