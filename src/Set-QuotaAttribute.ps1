param
(
    [Parameter(Mandatory = $true)]
    $mailboxes,
    [Parameter(Mandatory = $false)]
    $listToCSV = $true
)

Remove-Module QuotaModule -ErrorAction SilentlyContinue
Import-Module ..\Modules\QuotaModule.ps1

# list all mailboxes without mark in customattribute15
# $mailboxes = get-mailbox -resultsize unlimited | ? {$_.customattribute15 -eq ""}

foreach($mbx in $mailboxes)
{
    # get 3 levels of quotas to list
    $quota = @()
    $quota += (($mbx | 
        select -ExpandProperty IssueWarningQuota).tostring().split("(")[0]
        )
    $quota += (($mbx | 
        select -ExpandProperty prohibitsendquota).tostring().split("(")[0]
        )
    $quota += (($mbx | 
        select -ExpandProperty ProhibitSendReceiveQuota).tostring().split("(")[0]
        )

    # due to the parsing problems ordinary variables are used
    [string]$currentIssueWarningQuota = $quota[0]
    [string]$currentProhibitSendQuota = $quota[1]
    [string]$currentProhibitSendReceiveQuota = $quota[2]


    # set vip size for unlimited users
    if($($quota[0]) -eq "Unlimited")
    {
        $customAttribute = Pick-CustomOrVip($mbx)
    }

    # if not vip
    else
    {
        $quota[1] = $($quota[1]).split(" ")
        $size = [int]$quota[1][0]
        $bytes = $quota[1][1]

        # check if current size of mailbox is in GB or less
        if(("MB", "KB", "B") -match $bytes)
        {
            $customAttribute = Get-CustomAttribute(1)
        }

        # else if GB
        elseif("GB" -match $bytes)
        {
            if($size -le 2)
            {
                $customAttribute = Get-CustomAttribute(1)
            }

            elseif($size -le 4)
            {
                $customAttribute = Get-CustomAttribute(2)
            }

            else
            {
                $customAttribute = Pick-CustomOrVip($mbx)
            }
        }

        # if greater than GB
        else
        {
            $customAttribute = Pick-CustomOrVip($mbx)
        }
    }

    # $customAttribute is choosen now and ready to set


    if($listToCSV -eq $false)
    {
        set-mailbox $mbx -customattribute15 $customAttribute -WhatIf
    }

    else
    {
        "$($mbx | select -ExpandProperty alias);$currentIssueWarningQuota;$currentProhibitSendQuota;$currentProhibitSendReceiveQuota;$customAttribute" >> ".\$(get-date -Format "yyyyMMdd_hh")_quotaLogs.csv"
    }
}