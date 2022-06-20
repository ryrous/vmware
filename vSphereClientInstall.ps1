# Install vSphere Client
Write-Host "Installing vSphere Client"
$VIMedia = "D:\vsphere-Client\VMware-viclient.exe"
Start-Process $VIMedia -ArgumentList '/q /s /w /V" /qr"' -Wait -Verb RunAs
