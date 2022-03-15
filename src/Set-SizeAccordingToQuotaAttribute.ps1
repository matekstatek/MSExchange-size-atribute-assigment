param
(
    [Parameter(Mandatory = $true)]
    $mailboxes,
    [Parameter(Mandatory = $false)]
    $listToCSV = $true
)

Remove-Module QuotaModule -ErrorAction SilentlyContinue
Import-Module ..\Modules\QuotaModule.ps1

foreach($mbx in $mailboxes)
{
    $customAttribute = get-mailbox $mbx | 
        select -ExpandProperty customattribute15

    switch($customAttribute)
    {
        $(Get-CustomAttribute(1)) { $targetProhibitSendQuota = 2GB }
        $(Get-CustomAttribute(2)) { $targetProhibitSendQuota = 4GB }
        $(Get-CustomAttribute(3)) { $targetProhibitSendQuota = 10GB }
        $(get-CustomAttribute)    { $targetProhibitSendQuota = "Unlimited" }
    }

    if($targetProhibitSendQuota -eq "Unlimited")
    {
        $targetIssueWarningQuota = "Unlimited"
    }
    else
    {
        $targetIssueWarningQuota = $targetProhibitSendQuota - 0.1GB
    }
    
    $targetProhibitSendReceiveQuota = "Unlimited"
    

    if($listToCSV -eq $true)
    {
        if($targetProhibitSendQuota -ne "Unlimited")
        {
            "$customAttribute;$($($targetIssueWarningQuota/1GB));$($($targetProhibitSendQuota/1GB));$targetProhibitSendReceiveQuota" >> C:\Users\ka.i5.msobolewski257\Desktop\x.csv
        }

        else
        {
            "$customAttribute;$($targetIssueWarningQuota);$($targetProhibitSendQuota);$targetProhibitSendReceiveQuota" >> C:\Users\ka.i5.msobolewski257\Desktop\x.csv
        }
    }
    else
    {
        set-mailbox $mbx -targetIssueWarningQuota $targetIssueWarningQuota -targetProhibitSendQuota $targetProhibitSendQuota -targetProhibitSendReceiveQuota $targetProhibitSendReceiveQuota -whatif
    }
}
