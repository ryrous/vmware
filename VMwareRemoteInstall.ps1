$vmList = Get-Content .\VMList.txt
# Copy Installation Package to Destination Server
function Copy-File {
    foreach ($vmName in $vmList){
        Get-Item "C:\Directory\*" | Copy-VMGuestFile -Destination 'C:\Directory\' -VM $vm -LocalToGuest -GuestUser "domain\user" -GuestPassword Password -Confirm:$false
    }
}
# Run remote installation of McAfee on Server
function Get-Installation {
    foreach ($vmName in $vmList){
        Invoke-VMScript -VM $vmName -ScriptType Powershell -ScriptText (Start-Process -Filepath 'C:\Directory\NameofPackage.msi' -ArgumentList '/Silent') -GuestUser "domain\user" -GuestPassword Password -Confirm:$false
    }
}
# Execute
Copy-File | Wait-Job
Get-Installation | Wait-Job
