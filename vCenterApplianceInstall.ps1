# Deploy vCSA6 using vCSA-Deploy
# Convert JSON file to PowerShell object 
$ConfigLoc = "D:\vcsa-cli-installer\templates\full_conf.json"
$Installer = "D:\vcsa-cli-installer\win32\vcsa-deploy.exe"
$updatedconfig = "C:\Temp\configuration.json"
$json = (Get-Content -Raw $ConfigLoc) | ConvertFrom-Json

# vCSA system information
$json.vcsa.system."root.password"="VMware123"
$json.vcsa.system."ntp.servers"="198.60.73.8"
$json.vcsa.sso.password = "VMware123"
$json.vcsa.sso."site-name" = "Primary-Site"

# ESXi Host Information
$json.deployment."esx.hostname"="10.144.99.11"
$json.deployment."esx.datastore"="ISCSI-SSD-900GB"
$json.deployment."esx.username"="root"
​$json.deployment."esx.password"="VMware123"
$json.deployment."deployment.option"="tiny"
$json.deployment."deployment.network"="VM Network"
$json.deployment."appliance.name"="Primary-vCSA6"

# Database connection
$json.vcsa.database.type="embedded"

# Networking
$json.vcsa.networking.mode = "static"
$json.vcsa.networking.ip = "10.144.99.19"
$json.vcsa.networking.prefix = "24"
$json.vcsa.networking.gateway = "10.144.99.1"
$json.vcsa.networking."dns.servers"="10.144.99.5"
$json.vcsa.networking."system.name"="10.144.99.19"
$json | ConvertTo-Json | Set-Content -Path "$updatedconfig"

Invoke-Expression "$installer $updatedconfig"
