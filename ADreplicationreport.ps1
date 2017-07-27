$workfile = repadmin.exe /showrepl * /csv 
$results = ConvertFrom-Csv -InputObject $workfile | where {$_.'Number of Failures' -ge 1}
 
$results = $results | where {$_.'Number of Failures' -gt 1 }
 
if ($results -ne $null ) {
    $results = $results | select "Source DC", "Naming Context", "Destination DC" ,"Number of Failures", "Last Failure Time", "Last Success Time", "Last Failure Status"
    } else {
    $results = "There were no Replication Errors" | Out-file c:\somefolder\etc
}

$body = get-content -path "C:\somefolder\dcreptext.txt"

Send-MailMessage -To some@address.com -From some@address.com -Subject "Daily Forest Replication Report" -Body $body -SmtpServer 1.2.3.4