$AllHosts = @()
Get-VM * | ForEach-Object {
    $hoststat = "" | Select-Object HostName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin
    $hoststat.HostName = $_.Name
    $statcpu = Get-Stat -Entity $_ -Start (Get-Date).AddDays(-7) -Finish (Get-Date)-MaxSamples 100 -Stat cpu.usage.average
    $statmem = Get-Stat -Entity $_ -Start (Get-Date).AddDays(-7) -Finish (Get-Date)-MaxSamples 100 -Stat mem.usage.average
    $cpu = $statcpu | Measure-Object -Property value -Average -Maximum -Minimum
    $mem = $statmem | Measure-Object -Property value -Average -Maximum -Minimum
    $hoststat.CPUMax = $cpu.Maximum
    $hoststat.CPUAvg = $cpu.Average
    $hoststat.CPUMin = $cpu.Minimum
    $hoststat.MemMax = $mem.Maximum
    $hoststat.MemAvg = $mem.Average
    $hoststat.MemMin = $mem.Minimum
    $AllHosts += $hoststat
}
$AllHosts | Select-Object HostName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin | Export-Csv .\CPURAMHost.csv -NoTypeInformation
