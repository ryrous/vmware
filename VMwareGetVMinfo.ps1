$VmInfo = ForEach ($Datacenter in (Get-Datacenter)){
    ForEach ($VM in ($Datacenter | Get-VM | Where-Object {$_.PowerState -match "On"} | Get-VMGuest)){  
        $vm | Select-Object 
            @{N="VM_NAME#";E={$vm.Hostname}},
            @{N="VM_CPU_Core#";E={$vm.NumCPU}},
            @{N="VM_IP#";E={$vm.IPAddress}},
            @{N="VM_OS";E={$vm.OSFullName}},
            @{N="VM_DC";E={$Datacenter.name}},
            @{N="VM_NOTES";E={$Vm.VM.Notes}}
    }
}
$VmInfo | Export-Csv .\VMinfo.csv -NoTypeInformation
