$VMs = Get-VM -Name (Get-Content .\ServerList.txt)
foreach ($VM in $VMs) {
    $VM | ForEach-Object {Get-View $_.id} | Where-Object {$_.Guest.ToolsVersionStatus -ne "guestToolsCurrent"} | Select-Object Name, Server, @{ Name = "VMware Tools Version"; Expression = {$_.config.tools.toolsVersion}}, @{ Name = "VMwre Tools Status"; Expression = {$_.Guest.ToolsVersionStatus}} | Export-Csv .\VMToolsUpate.csv -Append -NoTypeInformation
}
