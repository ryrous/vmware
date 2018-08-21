$VMs = Import-Csv .\VMList.csv
function Copy-File {
    foreach ($VM in $VMs){
        Get-Item "C:\Directory\*" | Copy-VMGuestFile -Destination 'C:\Directory\' -VM $vm -LocalToGuest -GuestUser "domain\user" -GuestPassword Password -Confirm:$false
    }
}
