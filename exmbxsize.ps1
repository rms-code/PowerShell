Get-mailbox | get-mailboxstatistics | sort-object totalitemsize -descending | Select-Object DisplayName,TotalItemSize -First 10 > C:\exmbxlist.txt

$body = get-content -path C:\exmbxlist.txt | Out-String

Send-MailMessage -To some@user.com -From some@user.com -Subject "Exchange Mailbox Size Report(Top 10)" -Body $body -SmtpServer 1.2.3.4