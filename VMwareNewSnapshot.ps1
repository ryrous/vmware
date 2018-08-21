### TAKE A NEW SNAPSHOT OF VM ###
$VMs = Import-Csv .\VMList.csv
function New-Snapshot {
    foreach ($VM in $VMs) {
        New-Snapshot -VM $VM -Name $ComputerName.SNAPSHOT -Description "Snapshot" -Memory $false -Quiesce -Confirm $false
    }
}
New-Snapshot
