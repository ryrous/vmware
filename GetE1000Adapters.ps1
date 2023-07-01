$report = @()
foreach($cluster in Get-Cluster){
    foreach($rp in Get-ResourcePool -Location $cluster){
        foreach($vm in (Get-VM -Location $rp | Where-Object{Get-NetworkAdapter -VM $_ | Where-Object{$_.Type -eq 'e1000'}})){
            $report += $vm | Select-Object @{N='VM';E={$_.Name}},
                @{N='vCenter';E={$_.Uid.Split('@')[1].Split(':')[0]}},
                @{N='Cluster';E={$cluster.Name}},
                @{N='ResourcePool';E={$rp.Name}}
        }
   }
}
$report | Export-Csv .\E1000VMs.csv -NoTypeInformation -UseCulture