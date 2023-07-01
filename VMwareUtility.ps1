<# DOMAIN MIGRATION UTILITY - VERSION 1.1 #>

<#
REQUIREMENTS:
https://www.powershellgallery.com/packages/VMware.PowerCLI
https://www.powershellgallery.com/packages/Get-VMotion
#>

<# GENERAL #>
using namespace System.Management.Automation.Host

<# GENERAL VARIABLES #>
$VMs = Get-Content .\VMList.txt
$Domain = 'domain.com'
$DC = 'COMPUTERNAME'
$DCIP = '10.10.10.30'
$PingDomain = "ping $Domain"
$PingDC = "ping $DC.$Domain"
$PingDCIP = "ping $DCIP"
$GetSvcOnVM = "wmic service get name,startname | sort"
$GetDomainSvc = "wmic service get startname | find ""svc startname"" | sort"
$FWStatus = "netsh advfirewall show allprofiles state"
$FWDisable = "netsh advfirewall set allprofiles state off"


<# DOMAIN LOGIN VARIABLES #>
Write-Host "Let's get started! Please enter your Domain credentials." -ForegroundColor Magenta -BackgroundColor Black
$GuestUser = Read-Host "Enter your Domain UserName (Domain\UserName): "
$GuestPasswordSec = Read-Host "Enter your Domain Password: " -AsSecureString
$GuestPassword = ConvertFrom-SecureString -SecureString $GuestPasswordSec -AsPlainText
$GuestCreds = New-Object System.Management.Automation.PSCredential ($GuestUser, $GuestPasswordSec)

<# VCENTER LOGIN VARIABLES #>
Write-Host "Last step! Enter your vCenter password." -ForegroundColor Magenta -BackgroundColor Black
$vCenter = "10.10.10.20"
$vCenterUser = Read-Host "Enter your vCenter UserName (Domain\UserName): "
$vCenterPasswordSec = Read-Host "Enter your vCenter Password: " -AsSecureString
$vCenterPassword = ConvertFrom-SecureString -SecureString $vCenterPasswordSec -AsPlainText


<# FUNCTIONS #>
function Show-Menu {
    param (
        [string]$Title = 'Domain Migration Utility v1.1'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "VCENTER AND VMLIST.txt VERIFICATION" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "1: Press '1' to connect to vCenter." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "2: Press '2' to disconnect from vCenter." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "3: Press '3' to show VMs in VMList.txt" -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "4: Press '4' to see if VMs in VMList.txt are in vCenter." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "POWER STATE" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "11a: Press '11a' to check Power Status on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "11b: Press '11b' to check Power Status on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "12: Press '12' to reboot a specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "13: Press '13' to power on a specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "14: Press '14' to shutdown a specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "15: Press '15' to power off a specific VM." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "VMWARE TOOLS STATUS" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "16a: Press '16a' to check VMware Tools on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "16b: Press '16b' to check VMware Tools on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "17a: Press '17a' to update VMware Tools on specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "17b: Press '17b' to update VMware Tools on each VM." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "CPU AND MEMORY" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "21a: Press '21a' to get weekly CPU and Memory usage report on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "21b: Press '21b' to get weekly CPU and Memory usage report on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "22a: Press '22a' to get monthly CPU and Memory usage report on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "22b: Press '22b' to get monthly CPU and Memory usage report on each VM." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "SERVICES" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "31a: Press '31a' to get all services on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "31b: Press '31b' to get all services on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "32a: Press '32a' to check for a specific Service on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "32b: Press '32b' to check for a specific Service on each VM." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "NETWORK CONNECTIVITY" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "41a: Press '41a' to ping ComputerName of specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "41b: Press '41b' to ping ComputerName of each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "42a: Press '42a' to ping IP Address of specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "42b: Press '42b' to ping IP Address of each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "44a: Press '44a' to test reachability of DC from specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "44b: Press '44b' to test reachability of DC from each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "44c: Press '44c' to test reachability of DC IP from each VM." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "WINDOWS FIREWALL" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "51a: Press '51a' to get status of Windows Firewall on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "51b: Press '51b' to get status of Windows Firewall on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "52a: Press '52a' to disable Windows Firewall on specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "52b: Press '52b' to disable Windows Firewall on each VM." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "BACKUP POLICY" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "61a: Press '61a' to check Backup Policy on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "61b: Press '61b' to check Backup Policy on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "62a: Press '62a' to set Backup Policy on specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "62b: Press '62b' to set Backup Policy on each VM." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "SNAPSHOTS" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "71a: Press '71a' to take Snapshot of specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "71b: Press '71b' to take Snapshot of each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "72a: Press '72a' to remove all Snapshots of specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "72b: Press '72b' to remove all Snapshots of each VM." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "VMOTION" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "81a: Press '81a' to get 24-hours of VMotion events of specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "81b: Press '81b' to get 24-hours of VMotion events of each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "82a: Press '82a' to get 1-week of VMotion events of specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "82b: Press '82b' to get 1-week of VMotion events of each VM." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "Q: Press 'Q' to quit."
}


<# VCENTER AND LIST VERIFICATION #>
function Connect-2vCenter {
    Connect-VIServer -Server $vCenter -User $vCenterUser -Password $vCenterPassword
}

function Get-LocationOfVMs {
    if (VMware.VimAutomation.Core\Get-VM $VM) {
        Write-Host "$VM exists in vCenter" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "$VM does not exist in vCenter" -ForegroundColor Red -BackgroundColor Black
    }
}

<# VM SPECIFIC #>
function Get-PowerStatusOfVM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting Power Status of $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $TargetVM) | Select-Object Powerstate
}

function Get-PowerStatusOfVMAll {
    Write-Host "Getting Power Status of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $VM) | Select-Object Powerstate
}

function Invoke-RebootOfVM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Restarting $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    Restart-VMGuest $TargetVM
}

function Start-PoweredOffVM {
    Write-Host "Starting $VM" -ForegroundColor Blue -BackgroundColor Black
    Start-VM -VM $VM -Confirm:$false
}

function Invoke-ShutdownOfVM {
    Write-Host "Shutting down $VM" -ForegroundColor Blue -BackgroundColor Black
    Shutdown-VMGuest -VM $VM -Confirm:$False
}

function Invoke-PowerOffOfVM {
    Write-Host "Starting $VM" -ForegroundColor Blue -BackgroundColor Black
    Stop-VM -VM $VM -Confirm:$False
}

<# VMWARE TOOLS STATUS #>
function Get-VMwareToolsStatusOfVM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting VMware Tools Status of $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    ((VMware.VimAutomation.Core\Get-VM $TargetVM) | Get-View).Guest.ToolsStatus
}

function Get-VMwareToolsStatusOfVMAll {
    Write-Host "Getting VMware Tools Status of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    ((VMware.VimAutomation.Core\Get-VM $VM) | Get-View).Guest.ToolsStatus
}

function Update-VmWareToolsOnVM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Updating VmWare Tools on $TargetVM" -ForegroundColor Blue -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $TargetVM) | Update-Tools -NoReboot
}

function Update-VmWareToolsOnVMAll {
    Write-Host "Updating VmWare Tools on $VM" -ForegroundColor Blue -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $VM) | Update-Tools -NoReboot
}

<# CPU AND MEMORY #>
function Get-WeeklyCPURAM4VM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting CPU and Memory Weekly Usage Report for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $AllVMs = @()
    (VMware.VimAutomation.Core\Get-VM $TargetVM) | ForEach-Object {
        $vmstat = “” | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax
        $vmstat.VmName = "$TargetVM"
        $statcpuweek = Get-Stat -Entity ($TargetVM) -Start (Get-Date).AddDays(-7) -Finish (Get-Date) -MaxSamples 100 -Stat cpu.usage.average
        $statmemweek = Get-Stat -Entity ($TargetVM) -Start (Get-Date).AddDays(-7) -Finish (Get-Date) -MaxSamples 100 -Stat mem.usage.average
        $cpuweek = $statcpuweek | Measure-Object -Property Value -Average -Maximum -Minimum
        $memweek = $statmemweek | Measure-Object -Property Value -Average -Maximum -Minimum
        $vmstat.CPUMax = [math]::Round($cpuweek.Maximum)
        $vmstat.CPUAvg = [math]::Round($cpuweek.Average)
        $vmstat.CPUMin = [math]::Round($cpuweek.Minimum)
        $vmstat.MemMax = [math]::Round($memweek.Maximum)
        $vmstat.MemAvg = [math]::Round($memweek.Average)
        $vmstat.MemMin = [math]::Round($memweek.Minimum)
        $AllVMs += $vmstat
    }
    $AllVMs | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax
}

function Get-WeeklyCPURAM4All {
    Write-Host "Getting CPU and Memory Weekly Usage Report for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $AllVMs = @()
    (VMware.VimAutomation.Core\Get-VM $VM) | ForEach-Object {
        $vmstat = “” | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax
        $vmstat.VmName = "$VM"
        $statcpuweek = Get-Stat -Entity ($VM) -Start (Get-Date).AddDays(-7) -Finish (Get-Date) -MaxSamples 100 -Stat cpu.usage.average
        $statmemweek = Get-Stat -Entity ($VM) -Start (Get-Date).AddDays(-7) -Finish (Get-Date) -MaxSamples 100 -Stat mem.usage.average
        $cpuweek = $statcpuweek | Measure-Object -Property Value -Average -Maximum -Minimum
        $memweek = $statmemweek | Measure-Object -Property Value -Average -Maximum -Minimum
        $vmstat.CPUMax = [math]::Round($cpuweek.Maximum)
        $vmstat.CPUAvg = [math]::Round($cpuweek.Average)
        $vmstat.CPUMin = [math]::Round($cpuweek.Minimum)
        $vmstat.MemMax = [math]::Round($memweek.Maximum)
        $vmstat.MemAvg = [math]::Round($memweek.Average)
        $vmstat.MemMin = [math]::Round($memweek.Minimum)
        $AllVMs += $vmstat
    }
    $AllVMs | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax
}

function Get-MonthlyCPURAM4VM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting CPU and Memory Monthly Usage Report for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $AllVMs = @()
    (VMware.VimAutomation.Core\Get-VM $TargetVM) | ForEach-Object {
        $vmstat = “” | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax
        $vmstat.VmName = "$TargetVM"
        $statcpumonth = Get-Stat -Entity ($TargetVM) -Start (Get-Date).AddDays(-30) -Finish (Get-Date) -MaxSamples 1000 -Stat cpu.usage.average
        $statmemmonth = Get-Stat -Entity ($TargetVM) -Start (Get-Date).AddDays(-30) -Finish (Get-Date) -MaxSamples 1000 -Stat mem.usage.average
        $cpumonth = $statcpumonth | Measure-Object -Property value -Average -Maximum -Minimum
        $memmonth = $statmemmonth | Measure-Object -Property value -Average -Maximum -Minimum
        $vmstat.CPUMax = [math]::Round($cpumonth.Maximum)
        $vmstat.CPUAvg = [math]::Round($cpumonth.Average)
        $vmstat.CPUMin = [math]::Round($cpumonth.Minimum)
        $vmstat.MemMax = [math]::Round($memmonth.Maximum)
        $vmstat.MemAvg = [math]::Round($memmonth.Average)
        $vmstat.MemMin = [math]::Round($memmonth.Minimum)
        $AllVMs += $vmstat
    }
    $AllVMs | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax
}

function Get-MonthlyCPURAM4All {
    Write-Host "Getting CPU and Memory Monthly Usage Report for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $AllVMs = @()
    (VMware.VimAutomation.Core\Get-VM $VM) | ForEach-Object {
        $vmstat = “” | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax
        $vmstat.VmName = "$VM"
        $statcpumonth = Get-Stat -Entity ($VM) -Start (Get-Date).AddDays(-30) -Finish (Get-Date) -MaxSamples 1000 -Stat cpu.usage.average
        $statmemmonth = Get-Stat -Entity ($VM) -Start (Get-Date).AddDays(-30) -Finish (Get-Date) -MaxSamples 1000 -Stat mem.usage.average
        $cpumonth = $statcpumonth | Measure-Object -Property value -Average -Maximum -Minimum
        $memmonth = $statmemmonth | Measure-Object -Property value -Average -Maximum -Minimum
        $vmstat.CPUMax = [math]::Round($cpumonth.Maximum)
        $vmstat.CPUAvg = [math]::Round($cpumonth.Average)
        $vmstat.CPUMin = [math]::Round($cpumonth.Minimum)
        $vmstat.MemMax = [math]::Round($memmonth.Maximum)
        $vmstat.MemAvg = [math]::Round($memmonth.Average)
        $vmstat.MemMin = [math]::Round($memmonth.Minimum)
        $AllVMs += $vmstat
    }
    $AllVMs | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax
}

<# SERVICES #>
function Get-ServicesOnVM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting List of all Services on $TargetVM"
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetSvcOnVM
    $SO.ScriptOutput
}

function Get-ServicesAll {
    Write-Host "Getting List of all Services on $VM"
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetSvcOnVM
    $SO.ScriptOutput
}

function Get-SpecificSVC {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Finding Service on $TargetVM"
    $SO1 = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetDomainSvc
    if ($SO1.ScriptOutput -like "*biz*") {
        Write-Host "Service Found on $TargetVM" -ForegroundColor Red -BackgroundColor Black
        $SO1.ScriptOutput
    } else {
        Write-Host "Service not Found on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    }
}

function Get-SpecificSVCAll {
    Write-Host "Finding Service on $VM"
    $SO1 = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetDomainSvc
    if ($SO1.ScriptOutput -like "*biz*") {
        Write-Host "Service Found on $VM" -ForegroundColor Red -BackgroundColor Black
        $SO1.ScriptOutput
    } else {
        Write-Host "Service not Found on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    }
}

<# NETWORK CONNECTIVITY #>
function Get-PingStatus {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Pinging $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    Test-Connection -TargetName $TargetVM -ResolveDestination | Select-Object -ExpandProperty Status
}

function Get-PingStatusAll {
    Write-Host "Pinging $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    Test-Connection -TargetName $VM -ResolveDestination | Select-Object -ExpandProperty Status
}

function Get-PingStatusIP {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Pinging IP of $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $IP = (VMware.VimAutomation.Core\Get-VM $TargetVM).Guest.IPAddress[0]
    Test-Connection -TargetName $IP -IPv4 -ResolveDestination | Select-Object -ExpandProperty Status
}

function Get-PingStatusIPAll {
    Write-Host "Pinging IP of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $IP = (VMware.VimAutomation.Core\Get-VM $VM).Guest.IPAddress[0]
    Test-Connection -TargetName $IP -IPv4 -ResolveDestination | Select-Object -ExpandProperty Status
}

function Test-ReachDomain {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Testing BIZ DC Reachability from $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Powershell -ScriptText $PingDC
    $SO.ScriptOutput
}

function Test-ReachDomainAll {
    Write-Host "Testing BIZ DC Reachability from $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Powershell -ScriptText $PingDC
    $SO.ScriptOutput
}

function Test-ReachDomainDCIP {
    Write-Host "Testing BIZ DC IP Reachability from $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Powershell -ScriptText $PingDCIP
    $SO.ScriptOutput
}

<# WINDOWS FIREWALL #>
function Get-WinFirewallStatus {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting Firewall Status on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPasswordSec -ScriptType Bat -ScriptText $FWStatus
    $SO.ScriptOutput
}

function Get-WinFirewallStatusAll {
    Write-Host "Getting Firewall Status on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPasswordSec -ScriptType Bat -ScriptText $FWStatus
    $SO.ScriptOutput
}

function Set-WinFirewallOff {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Disabling Windows Firewall on $TargetVM" -ForegroundColor Blue -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $FWDisable
    $SO.ScriptOutput
}

function Set-WinFirewallOffAll {
    Write-Host "Disabling Windows Firewall on $VM" -ForegroundColor Blue -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $FWDisable
    $SO.ScriptOutput
}

<# BACKUP POLICY #>
function Show-BackupPolicy4VM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    $Attribute = Read-Host -Prompt "Enter the CustomAttribute to search for: "
    Write-Host "Checking Backup Policy on $TargetVM"
    $BUExclude = Get-Annotation -Entity $TargetVM -CustomAttribute $Attribute | Select-Object Value
    if ($BUExclude.Value -eq $Attribute) {
        Write-Host "Backup Policy on $TargetVM set to $Attribute" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "Backup Policy on $TargetVM NOT set to $Attribute" -ForegroundColor Red -BackgroundColor Black
    }
}

function Show-BackupPolicy4All {
    $Attribute = Read-Host -Prompt "Enter the CustomAttribute to search for: "
    Write-Host "Checking Backup Policy on $VM"
    $BUExclude = Get-Annotation -Entity $VM -CustomAttribute $Attribute | Select-Object Value
    if ($BUExclude.Value -eq $Attribute) {
        Write-Host "Backup Policy on $VM set to $Attribute" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "Backup Policy on $VM NOT set to $Attribute" -ForegroundColor Red -BackgroundColor Black
    }
}

function Set-BackupPolicy4VM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    $Attribute = Read-Host -Prompt "Enter the CustomAttribute to apply: "
    Write-Host "Setting VMs Backup Policy to $Attribute" 
    if ((Get-Annotation -Entity $TargetVM -CustomAttribute $Attribute | Select-Object Value) -ne "Exclude") {
            Write-Host "Setting Backup Policy on $TargetVM to $Attribute" -ForegroundColor Blue -BackgroundColor Black
            Set-Annotation -Entity $TargetVM -CustomAttribute $Attribute -Value "Exclude" 
        }
    Write-Host "Finished setting Backup Policy on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
}

function Set-BackupPolicy4All {
    $Attribute = Read-Host -Prompt "Enter the CustomAttribute to apply: "
    Write-Host "Setting VMs Backup Policy to $Attribute" 
    if ((Get-Annotation -Entity $VM -CustomAttribute $Attribute | Select-Object Value) -ne "Exclude") {
            Write-Host "Setting Backup Policy on $VM to $Attribute" -ForegroundColor Blue -BackgroundColor Black
            Set-Annotation -Entity $VM -CustomAttribute $Attribute -Value "Exclude" 
        }
    Write-Host "Finished setting Backup Policy on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
}

<# SNAPSHOT FUNCTIONS #>
function New-Snap4Salvation {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Creating new snapshot of $TargetVM" -ForegroundColor Blue -BackgroundColor Black
    New-Snapshot -VM $TargetVM -Name $TargetVM.SNAPSHOT -Description "Snapshot" -Quiesce -Memory:$false -Confirm:$false
    Write-Host "Finished creating new snapshot of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
}

function New-Snap4SalvationAll {
    Write-Host "Creating new snapshot of $VM" -ForegroundColor Blue -BackgroundColor Black
    New-Snapshot -VM $VM -Name $VM.SNAPSHOT -Description "Snapshot" -Quiesce -Memory:$false -Confirm:$false
    Write-Host "Finished creating new snapshot of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
}

function Remove-AllSnapshots4VM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Removing Snapshots for $TargetVM" -ForegroundColor Blue -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $TargetVM) | Get-Snapshot | ForEach-Object {Remove-Snapshot $_ -Confirm:$false}
    Write-Host "Finished removing Snapshots for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black

}

function Remove-AllSnapshots4All {
    Write-Host "Removing Snapshots for each $VM" -ForegroundColor Blue -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $VM) | Get-Snapshot | ForEach-Object {Remove-Snapshot $_ -Confirm:$false}
    Write-Host "Finished removing Snapshots for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
}

<# VMOTION #>
function Get-DailyVmotion4VM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting 24-hour vMotion events for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $TargetVM) | Get-VMotion -Days 1 | Format-List *
}

function Get-DailyVmotion4All {
    Write-Host "Getting 24-hour vMotion events for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $VM) | Get-VMotion -Days 1 | Format-List *
}

function Get-WeeklyVmotion4VM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting 24-hour vMotion events for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $TargetVM) | Get-VMotion -Days 7 | Format-List *
}

function Get-WeeklyVmotion4All {
    Write-Host "Getting 24-hour vMotion events for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $VM) | Get-VMotion -Days 7 | Format-List *
}

<# EXECUTE INTERACTIVE MENU #>
do {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        <# VCENTER AND LIST VERIFICATION #>
        '1' {
            'Connecting to vCenter...'
            Connect-2vCenter
        }
        '2' {
            'Disconnecting from vCenter...'
            Disconnect-VIServer
        }
        '3' {
            'Getting list of VMs...'
            Get-Content .\VMList.txt
        }
        '4' {
            'Checking list of VMs for existence in vCenter...'
            foreach ($VM in $VMs) {
                Get-LocationOfVMs
            }
        }
        <# VM SPECIFIC #>
        '11a' {
            'Getting Power Status of VM...'
            Get-PowerStatus4VM
        }
        '11b' {
            'Getting Power Status of VMs...'
            foreach ($VM in $VMs) {
                Get-PowerStatus4VMAll
            }
        }
        '12' {
            'Initiating Reboot of VM...'
            Invoke-RebootOfVM
        }
        
        '13' {
            'Powering On VM...'
            Start-PoweredOffVM
        }
        '14' {
            'Shutting Down VM...'
            Invoke-ShutdownOfVM
        }
        '15' {
            'Powering Off VM...'
            Invoke-PowerOffOfVM
        }
        <# VMWARE TOOLS STATUS #>
        '16b' {
            'Getting VMware Tools Status on VM...'
            Get-VMwareToolsStatusOfVM
        }
        '16b' {
            'Getting VMware Tools Status on VMs...'
            foreach ($VM in $VMs) {
                Get-VMwareToolsStatusOfVMAll
            }
        }
        '17a' {
            'Updating VMware Tools on VM...'
            Update-VmWareToolsOnVM
        }
        '17b' {
            'Updating VMware Tools on VMs...'
            foreach ($VM in $VMs) {
                Update-VmWareToolsOnVMAll
            }
        }
        <# CPU AND MEMORY #>
        '21a' {
            'Checking CPU and Memory on VM...'
            Get-WeeklyCPURAM4VM
        }
        '21b' {
            'Checking CPU and Memory on VMs...'
            foreach ($VM in $VMs) {
                Get-WeeklyCPURAM4All
            }
        }
        '22a' {
            'Checking CPU and Memory on VM...'
            Get-MonthlyCPURAM4VM
        }
        '22b' {
            'Checking CPU and Memory on VMs...'
            foreach ($VM in $VMs) {
                Get-MonthlyCPURAM4All
            }
        }
        <# SERVICES #>
        '31a' {
            'Getting list of all Services on specific VM...'
            Get-ServicesOnVM
        }
        '31b' {
            'Getting list of all Services on each VM...'
            foreach ($VM in $VMs) {
                Get-ServicesAll
            }
        }
        '32a' {
            'Finding Service on specific VM...'
            Get-SpecificSVC
        }
        '32b' {
            'Finding Service on each VM...'
            foreach ($VM in $VMs) {
                Get-SpecificSVCAll
            }
        }
        <# NETWORK CONNECTIVITY #>
        '41a' {
            'Pinging specific VM by ComputerName...'
            Get-PingStatus
        }
        '41b' {
            'Pinging each VM by ComputerName...'
            foreach ($VM in $VMs) {
                Get-PingStatusAll
            }
        }
        '42a' {
            'Pinging specific VM by IP...'
            Get-PingStatusIP
        }
        '42b' {
            'Pinging each VM by IP...'
            foreach ($VM in $VMs) {
                Get-PingStatusIPAll
            }
        }
        '44a' {
            'Testing reachability of DC on specific VM...'
            Test-ReachDomain
        }
        '44b' {
            'Testing reachability of DC from each VM...'
            foreach ($VM in $VMs) {
                Test-ReachDomainAll
            }
        }
        '44c' {
            'Testing reachability of DC IP from each VM...'
            foreach ($VM in $VMs) {
                Test-ReachDomainDCIP
            }
        }
        <# WINDOWS FIREWALL #>
        '51a' {
            'Getting status of Windows Firewall on specific VM...'
            Get-WinFirewallStatus
        }
        '51b' {
            'Getting status of Windows Firewall on each VM...'
            foreach ($VM in $VMs) {
                Get-WinFirewallStatusAll
            }
        }
        '52a' {
            'Disabling Windows Firewall on specific VM...'
            Set-WinFirewallOff
        }
        '52b' {
            'Disabling Windows Firewall on each VM...'
            foreach ($VM in $VMs) {
                Set-WinFirewallOffAll
            }
        }
        <# BACKUP POLICY #>
        '61a' {
            'Show Backup Policy on VM...'
            Show-BackupPolicy4VM
        }
        '61b' {
            'Show Backup Policy on VMs...'
            foreach ($VM in $VMs) {
                Show-BackupPolicy4All
            }
        }
        '62a' {
            'Set Backup Policy on VM...'
            Set-BackupPolicy4VM
        }
        '62b' {
            'Set Backup Policy on VMs...'
            foreach ($VM in $VMs) {
                Set-BackupPolicy4All
            }
        }
        <# SNAPSHOTS #>
        '71a' {
            'Take Snapshot of specific VM...'
            New-Snap4Salvation
        }
        '71b' {
            'Take Snapshot of each VM...'
            foreach ($VM in $VMs) {
                New-Snap4SalvationAll
            }
        }
        '72a' {
            'Remove Snapshots of specific VM...'
            Remove-AllSnapshots4VM
        }
        '72b' {
            'Remove Snapshots of each VM...'
            foreach ($VM in $VMs) {
                Remove-AllSnapshots4All
            }
        }
        <# VMOTION #>
        '81a' {
            'Getting 24-hour vMotion events of VM...'
            Get-DailyVmotion4VM
        }
        '81b' {
            'Getting 24-hour vMotion events of VMs...'
            foreach ($VM in $VMs) {
                Get-DailyVmotion4All
            }
        }
        '82a' {
            'Getting 1-week vMotion events of VM...'
            Get-DailyVmotion4VM
        }
        '82b' {
            'Getting 1-week vMotion events of VMs...'
            foreach ($VM in $VMs) {
                Get-DailyVmotion4All
            }
        }
    }
    pause
}
until (
    $selection -eq 'q'
)
