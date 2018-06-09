#Groups to watch, add your own.
$adm_da = (Get-ADGroupMember "Domain Admins").Name
$adm_ea = (Get-ADGroupMember "Enterprise Admins").Name
$adm_bia = (Get-ADGroupMember "Administrators").Name

foreach($admin in $adm_da){if($admin -eq "Administrator"){}else{
Send-MailMessage -From "" -To "" -Subject "USER HAS BEEN ADDED TO DOMAIN ADMINS, IMMEDIATE ATTENTION!" -Body "USER HAS BEEN ADDED TO DOMAIN ADMINS, IMMEDIATE ATTENTION!" -SmtpServer ""
}}

foreach($admin2 in $adm_ea){if($admin2 -eq "Administrator"){}else{
Send-MailMessage -From "" -To "" -Subject "USER HAS BEEN ADDED TO ENTERPRISE ADMINS, IMMEDIATE ATTENTION!" -Body "USER HAS BEEN ADDED TO ENTERPRISE ADMINS, IMMEDIATE ATTENTION!" -SmtpServer ""
}}

foreach($admin3 in $adm_bia){if($admin3 -eq "Administrator" -or $admin3 -eq "Domain Admins" -or $admin3 -eq "Enterprise Admins"){}else{
Send-MailMessage -From "" -To "" -Subject "USER HAS BEEN ADDED TO BUILT-IN ADMINISTRATORS, IMMEDIATE ATTENTION!" -Body "USER HAS BEEN ADDED TO BUILTIN ADMINISTRATORS, IMMEDIATE ATTENTION!" -SmtpServer ""
}}