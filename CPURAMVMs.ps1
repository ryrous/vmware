$AllVMs = @()
Get-VM * | ForEach-Object {
    $vmstat = “” | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax
    $vmstat.VmName = $vm.name
    $statcpumonth = Get-Stat -Entity ($vm) -start (get-date).AddDays(-30) -Finish (Get-Date) -MaxSamples 1000 -stat cpu.usage.average
    $statmemmonth = Get-Stat -Entity ($vm) -start (get-date).AddDays(-30) -Finish (Get-Date) -MaxSamples 1000 -stat mem.usage.average
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
$AllVMs | Select-Object VmName, CPUMin, CPUAvg, CPUMax, MemMin, MemAvg, MemMax | Export-Csv “.\CPURAM4Month.csv” -NoTypeInformation
