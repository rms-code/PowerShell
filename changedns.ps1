#you could also use $var = get-adcomputer -filter * -searchbase "ou...." 
#then foreach($pc in $var){..}

$computer = ComputerNameHere
$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $computer |where{$_.IPEnabled -eq “TRUE”}
  Foreach($NIC in $NICs) {
$DNSServers = “1.2.3.4"
 $NIC.SetDNSServerSearchOrder($DNSServers)
 $NIC.SetDynamicDNSRegistration(“TRUE”)
}