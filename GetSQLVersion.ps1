$VM = Import-Csv -Path .\VMs.csv
$User = "Administrator"
$Pass = "Password"

$Script = '
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName | Where-Object -Property DisplayName -Like "Microsoft SQL Server*"
'

foreach ($VM in $VMs) {
    Invoke-VMScript -ScriptText $Script -VM $VM.Name -GuestUser $User -GuestPassword $Pass -ScriptType Powershell `
    | Select-Object -Property Name, ScriptOutput -ExpandProperty ScriptOutput | Out-File .\SQLVersions.txt -Append
}