$VMs = Get-VM -Name * | Where-Object {$_.PowerState -eq "PoweredOn"} | Select-Object Name 
foreach ($VM in $VMs){
    Get-VMHostNetworkAdapter -VMKernel | Select-Object VMhost, vmName, Name, Domain, IP, SubnetMask, Gateway, DNS1, DNS2, Mac, PortGroupName, vMotionEnabled, mtu, FullDuplex, BitRatePerSec | Export-Csv .\NetworkInfo.csv -Append -NoTypeInformation
}