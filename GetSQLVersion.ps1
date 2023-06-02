$VM = Import-Csv -Path .\VMs.csv
$User = "Administrator"
$Pass = "Password"

$Script = '
    $inst = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server").InstalledInstances
    ForEach ($i in $inst) {
        $p = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL").$i
        (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Edition
        (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").PatchLevel
    }'
 
foreach ($VM in $VMs) {
    Invoke-VMScript -ScriptText $Script -VM $VM.Name -GuestUser $User -GuestPassword $Pass -ScriptType Powershell | Export-Csv -Path .\SQLVersions.csv -Append -NoTypeInformation
}