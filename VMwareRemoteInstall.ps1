$VMs = Import-Csv .\VMList.csv
# Copy Installation Package to Destination Server
function Copy-File {
    foreach ($VM in $VMs){
        Get-Item "C:\Directory\*" | Copy-VMGuestFile -Destination 'C:\Directory\' -VM $vm -LocalToGuest -GuestUser "domain\user" -GuestPassword Password -Confirm:$false
    }
}
# Run remote installation of McAfee on Server
function Get-Installation {
    foreach ($VM in $VMs){
        Invoke-VMScript -VM $VM -ScriptType Powershell -ScriptText (Start-Process -Filepath 'C:\Directory\NameofPackage.msi' -ArgumentList '/Silent') -GuestUser "domain\user" -GuestPassword Password -Confirm:$false
    }
}
# Execute
Copy-File | Wait-Job
Get-Installation | Wait-Job
