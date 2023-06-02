$VM = Import-Csv -Path .\VMs.csv
$User = "Administrator"
$Pass = "Password"

Invoke-VMScript -ScriptText {
    $inst = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
    ForEach ($i in $inst) {
        $p = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$i
        (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Edition
        (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").PatchLevel
    }
} -VM $VM -GuestUser $User -GuestPassword $Pass -ScriptType Powershell