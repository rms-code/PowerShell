$adm_da = (Get-ADGroupMember "Domain Admins").Name
$adm_ea = (Get-ADGroupMember "Enterprise Admins").Name
$adm_bia = (Get-ADGroupMember "Administrators").Name

foreach($admin in $adm_da){if($admin -eq "Administrator" -or $admin -eq "someotherUSER"){}else{
Send-MailMessage -From "some@address.com" -To "some@address.com" -Subject "USER HAS BEEN ADDED TO DOMAIN ADMINS, IMMEDIATE ATTENTION!" -Body "USER HAS BEEN ADDED TO DOMAIN ADMINS, IMMEDIATE ATTENTION!" -SmtpServer "yourserver.com"
}}

foreach($admin2 in $adm_ea){if($admin2 -eq "Administrator" -or $admin2 -eq "someotherUSER"){}else{
Send-MailMessage -From "some@address.com" -To "some@address.com" -Subject "USER HAS BEEN ADDED TO ENTERPRISE ADMINS, IMMEDIATE ATTENTION!" -Body "USER HAS BEEN ADDED TO ENTERPRISE ADMINS, IMMEDIATE ATTENTION!" -SmtpServer "yourserver.com"
}}

foreach($admin3 in $adm_bia){if($admin3 -eq "Administrator" -or $admin3 -eq "Domain Admins" -or $admin3 -eq "Enterprise Admins"){}else{
Send-MailMessage -From "some@address.com" -To "some@address.com" -Subject "USER HAS BEEN ADDED TO BUILDIN ADMINISTRATORS, IMMEDIATE ATTENTION!" -Body "USER HAS BEEN ADDED TO BUILDIN ADMINISTRATORS, IMMEDIATE ATTENTION!" -SmtpServer "yourserver.com"
}}