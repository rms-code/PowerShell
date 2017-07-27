<#
.Synopsis
   Connects to specified Host Servers and resumes Replication
.DESCRIPTION
   Connects to specified Host Servers, processes through each VM, and verifies Replication is working. If not, it will clear out the replication statistics and resume replication.
.EXAMPLE
   Repair-VMReplication -ComputerName Server1,Server2
.EXAMPLE
    PS C:\> Repair-VMReplication -ComputerName Server1,Server2
    Checking Replication on VM1
    Replication is properly working on VM1
    Checking Replication on VM2
    Replication is properly working on VM2
    Checking Replication on VM3
    VM Replication is in Critical Error State, resetting stats and resuming Replication
    Sleeping for 5 Seconds...
    Checking Replication on VM3
    Replication is properly working on VM3
    All VM's are properly Replicating.
.NOTES
    Requires Failover Cluster Management Tools to be installed on all Cluster Nodes
    C:\>Get-WindowsFeature *cluster*

    Display Name                                            Name                       Install State
    ------------                                            ----                       -------------
    [X] Failover Clustering                                 Failover-Clustering            Installed
            [X] Failover Clustering Tools                   RSAT-Clustering                Installed
                [X] Failover Cluster Management Tools       RSAT-Clustering-Mgmt           Installed
#>
Function Repair-VMReplication
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [array]$ComputerName
    )

    Begin {
        If ($ComputerName -eq $null){
        $ComputerName = "SERVER1","SERVER2","SERVER3"
        }#End If
    }#End Begin
    Process {
    $ReplicationData = Get-VM -ComputerName $ComputerName | Where-Object ReplicationMode -EQ Primary | Get-VMReplication

Foreach ($VMReplica in $ReplicationData) {
    Write-Host "Checking Replication on" $VMReplica.Name -ForegroundColor Yellow
    
    $RetryCount = 0

    Do {
        If ($VMReplica.Health -eq "Warning" -and $VMReplica.State -eq "Resynchronizing") {
            Write-Host "VM Replication is Resynchronizing." -ForegroundColor Yellow
            Break
        }
        Elseif ($VMReplica.Health -eq "Critical" -and $VMReplica.State -eq "Resynchronizing") {
            Write-Host "VM Replication is Resynchronizing." -ForegroundColor Yellow
            Break
        }
        Elseif ($VMReplica.Health -eq "Critical" -and $VMReplica.State -eq "Error") {
            $RetryCount++
            #If VM Fails to start replicating after 5 tries, move the replica to another host
            If ($RetryCount -gt 5) {
                Write-Host "Moving " $VMReplica.Name "..." -ForegroundColor Green
                $Cluster = Invoke-Command -ComputerName $VMReplica.CurrentReplicaServerName {Get-Cluster} | ForEach-Object {$_.Name}
                Get-Cluster -Name $Cluster | Get-ClusterGroup -Name $VMReplica.Name | Move-ClusterVirtualMachineRole -MigrationType Quick
                #Suspend current replication
                Write-Host "Suspending replication for " + $VMReplica.Name
                Invoke-Command -ComputerName $VMReplica.PrimaryServer {Get-VM $VMReplica.Name | Get-VMReplication | Suspend-VMReplication}
                #Start Resync Process
                Write-Host "Starting resync process for " + $VMReplica.Name
                Invoke-Command -ComputerName $VMReplica.PrimaryServer {Get-VM $VMReplica.Name | Get-VMReplication | Resume-VMReplication -Resynchronize}
            }
            Write-Host "VM Replication is in Critical Error State, resetting stats and resuming Replication. It has done this $RetryCount time(s)." -ForegroundColor Red
            Get-VM -Name $VMReplica.Name -ComputerName $VMReplica.PrimaryServer | Get-VMReplication | Reset-VMReplicationStatistics
            Resume-VMReplication -ComputerName $VMReplica.PrimaryServer -VMName $VMReplica.Name
            Write-Host "Sleeping for 5 Seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
        Elseif ($VMReplica.Health -eq "Warning" -and $VMReplica.State -eq "Suspended") {
            Write-Host "VM Replication is in Suspended State, resetting stats and resuming Replication" -ForegroundColor Red
            Get-VM -Name $VMReplica.Name -ComputerName $VMReplica.PrimaryServer | Get-VMReplication | Reset-VMReplicationStatistics
            Resume-VMReplication -ComputerName $VMReplica.PrimaryServer -VMName $VMReplica.Name
            Write-Host "Sleeping for 5 Seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
        Elseif ($VMReplica.Health -eq "Critical" -and $VMReplica.State -eq "WaitingForStartResynchronize") {
            Write-Host "VM Replication is Waiting to Start Resynchronize, Resuming Replication" -ForegroundColor Red
            Get-VM -Name $VMReplica.Name -ComputerName $VMReplica.PrimaryServer | Get-VMReplication | Reset-VMReplicationStatistics
            Resume-VMReplication -ComputerName $VMReplica.PrimaryServer -VMName $VMReplica.Name -Resynchronize
            Write-Host "Sleeping for 5 Seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
        Elseif ($VMReplica.Health -eq "Warning" -and $VMReplica.State -eq "ReadyForInitialReplication") {
            Write-Host "VM Replication is Ready for Initial Replication, Starting Initial Replication" -ForegroundColor Red
            Start-VMInitialReplication -ComputerName $VMReplica.PrimaryServer -VMName $VMReplica.Name
            Write-Host "Sleeping for 30 Seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
        Elseif($VMReplica.Health -eq "Warning") {
            Get-VM -Name $VMReplica.Name -ComputerName $VMReplica.PrimaryServer | Get-VMReplication | Reset-VMReplicationStatistics
        }

        $VMReplicaHealth = Get-VM -ComputerName $VMReplica.ComputerName -Name $VMReplica.VMName | Get-VMReplication
        #Start-Sleep -Seconds 10
    }
    Until($VMReplicaHealth.Health -eq "Normal" -and $VMReplicaHealth.State -eq "Replicating")
    Write-Host "Replication is properly working on" $VMReplica.Name -ForegroundColor Green
}
    }#End Process
    End {
        Write-Host "All VM's are properly Replicating." -ForegroundColor Green
    }#End End
}

Repair-VMReplication