# Step 5. The Genesys version of the AWS cost-guard. Read-only.
# Genesys is billed by licence and usage under your contract, not by the hour, so there is no "meter" to stop.
# What you CAN check is how many lab objects exist, and whether anything is left after a destroy.
param([string]$Prefix = 'DH')
. "$PSScriptRoot\lib.ps1"
Get-GenesysToken

function Show-Count {
    param([string]$Label, [string]$Path)
    $r = Invoke-GenesysGet $Path
    $n = 0
    if ($r.PSObject.Properties.Name -contains 'total') { $n = $r.total }
    elseif ($r.PSObject.Properties.Name -contains 'entities') { $n = @($r.entities).Count }
    '  {0,-34} {1}' -f $Label, $n
}

Say "Objects in the org (all, not only lab)"
Show-Count 'Queues'          '/api/v2/routing/queues?pageSize=1'
Show-Count 'Architect flows' '/api/v2/flows?pageSize=1'
Show-Count 'IVR configs'     '/api/v2/architect/ivrs?pageSize=1'
Show-Count 'Schedules'       '/api/v2/architect/schedules?pageSize=1'
Show-Count 'Schedule groups' '/api/v2/architect/schedulegroups?pageSize=1'
Show-Count 'Skills'          '/api/v2/routing/skills?pageSize=1'
Show-Count 'Groups'          '/api/v2/groups?pageSize=1'
Show-Count 'Roles'           '/api/v2/authorization/roles?pageSize=1'
Show-Count 'Knowledge bases' '/api/v2/knowledge/knowledgebases?pageSize=1'
Show-Count 'Integrations'    '/api/v2/integrations?pageSize=1'

Say "Queues with the $Prefix prefix (lab objects)"
$q = Invoke-GenesysGet "/api/v2/routing/queues?pageSize=100&name=$Prefix*"
foreach ($e in @($q.entities)) { "  $($e.name)" }

Say "Reminder"
'  - Check usage and charges in Genesys Admin > Billing, and in your contract.'
'  - A leftover phone number or add-on licence is where lab cost hides, not the queues.'
