$vmList = Get-Content .\Servers.txt
foreach ($vm in $vmList){
    Get-Item .\McAfee\McAfee.zip | Copy-VMGuestFile -Destination "C:\McAfee\" -VM $vm -LocalToGuest -GuestUser Administrator -GuestPassword PASSWORD -Force
}
