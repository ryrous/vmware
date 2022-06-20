Get-VM -Name * | Where-Object {$_.PowerState -eq "PoweredOn"} | Select-Object Name | Export-Csv -Path .\VMlist.csv -NoTypeInformation
$VMs = Import-Csv -Path .\VMlist.csv
foreach ($VM in $VMs){
    Get-VMHostNetworkAdapter -VMKernel | Select-Object VMhost, vmName, Name, Domain, IP, SubnetMask, Gateway, DNS1, DNS2,  Mac, PortGroupName, vMotionEnabled, mtu, FullDuplex, BitRatePerSec | Export-Csv .\NetworkInfo.csv -Append -NoTypeInformation
}
