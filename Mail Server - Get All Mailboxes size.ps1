Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox | Get-MailboxStatistics |
Select DisplayName, @{n="Total Size (MB)";e={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}}, StorageLimitStatus


$Result=@() 
#Get all user mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
 
#Get all shared mailboxes
#$mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox
 
$totalmbx = $mailboxes.Count
$i = 0 
$mailboxes | ForEach-Object {
$mbx = $_
#Get mailbox statistics 
$mbs = Get-MailboxStatistics -Identity $mbx.Identity
 
$i++
Write-Progress -activity "Processing $mbx" -status "$i out of $totalmbx completed"
 
if ($mbs.TotalItemSize -ne $null){
$size = [math]::Round(($mbs.TotalItemSize.ToString().Split('(')[1].Split(' ')[0].Replace(',','')/1MB),2)
}else{
$size = 0 }
 
$Result += New-Object -TypeName PSObject -Property $([ordered]@{
Name = $mbx.DisplayName
PrimarySmtpAddress = $mbx.PrimarySmtpAddress
AliasSmtpAddresses = ($mbx.EmailAddresses | Where-Object {$_ -clike 'smtp:*'} | ForEach-Object {$_ -replace 'smtp:',''}) -join ';'
TotalSizeInMB = $size
SizeWarningQuota=$mbx.IssueWarningQuota
StorageSizeLimit = $mbx.ProhibitSendQuota
StorageLimitStatus = $mbs.ProhibitSendQuota
})
}
$Result | Export-CSV "C:\Temp\MailboxSizeReport.csv" -NoTypeInformation -Encoding UTF8








$results = ForEach($mb in $mailboxes){
    $stats=get-mailboxstatistics $mb
    if ($mb.ProhibitSendQuota -eq 'Unlimited') {
        $freespace = 'Unlimited'
    } 
    else {
        $totalBytes = [double]($stats.totalitemsize -replace '.*?\((.*?) bytes.*','$1')
        $prohibitBytes = [double]($mb.ProhibitSendQuota -replace '.*?\((.*?) bytes.*','$1')
        $freespace = [Math]::Round(($prohibitBytes - $totalbytes)/1GB,2)
    }
    $props=@{
        alias=$mb.alias
        DisplayName=$mb.displayname
        #StorageLimitStatus=$stats.StorageLimitStatus
        TotalItemSize=$stats.totalitemsize
        #DatabaseName=$stats.databasename
        ProhibitSendQuota=$mb.ProhibitSendQuota
        ProhibitsendReceiveQuota=$mb.ProhibitsendReceiveQuota
        IssueWarningQuota=$mb.IssueWarningQuota
        FreeSpace=$freespace
    }
    [pscustomobject]$props
}

$results | Sort-Object TotalItemSize -descending | export-csv c:\script\report.csv -NoTypeInformation -Encoding UTF8