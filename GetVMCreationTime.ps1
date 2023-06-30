$vmName = '*'
$eventTYpes = 'VmCreatedEvent', 'VmClonedEvent', 'VmDeployedEvent', 'VmRegisteredEvent'

Get-VM -Name $vmName | ForEach-Object -Process {
   Get-VIEvent -Entity $_ -MaxSamples ([int]::MaxValue) | `
   Where-Object {$eventTYpes -contains $_.GetType().Name} | `
   Sort-Object -Property CreatedTime -Descending | `
   Select-Object -First 1 | `
   ForEach-Object -Process {New-Object PSObject -Property ([ordered]@{VM = $_.VM.Name; CreatedTime = $_.CreatedTime; User = $_.UserName; EventType = $_.GetType().Name})}
}