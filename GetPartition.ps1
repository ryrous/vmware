#### Get partitions in Guest OS ####
#Get-VM $VM | Get-VMGuestPartition
#Get-VM -Name * | Get-VMGuestPartition | Where-Object {$_.FreeSpaceMB -lt 1000} | Format-Table -AutoSize
#Get-VM -Name * | Get-VMGuestPartition | Where-Object {$_.Volume -eq C:\} | Where-Object {$_.FreeSpaceMB -lt 1000} | Export-Csv .\PartitionsLT1GB.csv -NoTypeInformation
#Get-VM -Name * | Get-VMGuestPartition | Where-Object {$_.'Usage%' -gt 85} | Out-Gridview
Get-VM -Name * | Get-VMGuestPartition | Where-Object {$_.Volume -eq 'C:\'} | Where-Object {$_.'Usage%' -gt 85} | Export-Csv .\Partitions85Percent.csv -NoTypeInformation
