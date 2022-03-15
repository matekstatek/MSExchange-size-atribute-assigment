param
(
    [Parameter(Mandatory = $true)]
    $Alias,
    [Parameter(Mandatory = $true)]
    [ValidateSet("ordinary", "boosted", "vip", "unlimited")]
    [string]$SizeAttribute
)

$mbx = get-mailbox $alias

Set-Mailbox $mbx -CustomAttribute15 $SizeAttribute

.\Set-SizeAccordingToQuotaAttribute -mailboxes $mbx -listToCSV $false