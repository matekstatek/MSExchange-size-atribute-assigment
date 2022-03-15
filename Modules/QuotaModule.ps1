function Get-CustomAttribute
{
    param
    (
        [Parameter()]
        [int]$level
    )

    switch($level)
    {
        1       { return "ordinary" }
        2       { return "boosted" }
        3       { return "vip" }
        default { return "unlimited" }
    }
}

function Get-TotalItemSize
{
    param
    (
        [Parameter(Mandatory = $true)]
        $mbx
    )

    $size = $mbx | 
        Get-MailboxStatistics | 
            select -ExpandProperty totalitemsize | 
                select -ExpandProperty value 

    $size = ([string]$size).split("(")[0]
    $bytes = $size.split(" ")[1]
    $size = [int]$($size.split(" ")[0])
    $size = $size * "1$bytes"

    return $size
}

function Pick-CustomOrVip
{
    param
    (
        [Parameter(Mandatory = $true)] $mbx
    )

    $stats = $mbx | 
        Get-MailboxStatistics -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

    # user didnt log in yet
    if($stats -eq $null)
    {
        return [string]$(Get-CustomAttribute(1))
    }

    $size = Get-TotalItemSize($mbx)

    if($size -lt 10GB)
    {
        $customAttribute = Get-CustomAttribute(3)
    }

    else
    {
        $customAttribute = Get-CustomAttribute
    }

    return $customAttribute
}