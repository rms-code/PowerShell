<#
.SYNOPSIS
    .
.DESCRIPTION
    .
.PARAMETER Path
    The path to the .
.PARAMETER LiteralPath
    Specifies a path to one or more locations. Unlike Path, the value of 
    LiteralPath is used exactly as it is typed. No characters are interpreted 
    as wildcards. If the path includes escape characters, enclose it in single
    quotation marks. Single quotation marks tell Windows PowerShell not to 
    interpret any characters as escape sequences.
#>
Param(

    [parameter(
                Mandatory=$True,
                HelpMessage='Path + VHDX ie: e:\vms\server\drive1.vhdx')]
               
                [string]$VHDXPATH_NAME,

    [parameter(
                Mandatory=$true,
                HelpMessage='VHD Size in GB, ie 50')]
               
                [string]$VHDSize,

    [parameter(
                Mandatory=$True,
                HelpMessage='VM Name')]
               
                [string]$VMNAME,

    [parameter(
                Mandatory=$true,
                HelpMessage='VM_MEMORY in GB, ie: 4')]
               
                [string]$VM_MEMORY,

    [parameter(
                Mandatory=$true,
                HelpMessage='VM Network, run get-vmswitch to find out')]
               
                [string]$VM_Network_Name,
    [parameter(
                Mandatory=$true,
                HelpMessage='CPU Count ie: 2')]
               
                [string]$CPUCOUNT,
    [parameter(
                Mandatory=$true,
                HelpMessage='Smartpaging File Path')]
               
                [string]$SmartPagePath,
    [parameter(
                Mandatory=$true,
                HelpMessage='Snapshot Path')]
               
                [string]$SnapshotPath,
    [parameter(
                Mandatory=$false,
                HelpMessage='ISO Location ie: E:\en_server2016_blabla.iso')]
               
                [string]$ISOLOCATION,
    [parameter(
                Mandatory=$false,
                HelpMessage='Add to cluster, add $true')]
               
                [bool]$CLVM
)
$VMGB = [System.UInt64] $vhdSize*1024*1024*1024
$VMMEM = [System.UInt64] $VM_MEMORY*1024*1024*1024
New-VHD -Path $VHDXPATH_NAME -SizeBytes $VMGB -Fixed
New-VM -name $VMNAME -MemoryStartupBytes $VMMEM -SwitchName "$VM_Network_Name"
Add-VMHardDiskDrive -VMName $VMNAME -ControllerType SCSI -ControllerNumber 0 -Path $VHDXPATH_NAME
if ($ISOLOCATION -ne $null) {Set-VMDvdDrive -VMName $VMNAME -Path $ISOLOCATION}
set-vm $VMNAME -ProcessorCount $CPUCOUNT -StaticMemory -AutomaticStartAction Nothing -SmartPagingFilePath $SmartPagePath -SnapshotFileLocation $SnapshotPath
if ($CLVM -eq $true){Add-ClusterVirtualMachineRole -VirtualMachine $VMNAME}