# Media
$VUMMedia = "D:\updateManager"
 
# Database
$DSN = "VUM"
$User = "vCenter"
$Pass = "VMware123"
 
# vCenter
$vCenter = "10.144.99.16"
$port = "80"
$vCAdmin = "administrator@vsphere.local"
$vCAdmin_Pass = "VMware123"

$vArgs = "/V`" /qr /L*v c:\temp\vmvci.log "
$vArgs += "WARNING_LEVEL=0 VCI_DB_SERVER_TYPE=Custom "
$vArgs += "DB_DSN=$DSN DB_USERNAME=$user "
$vArgs += "DB_PASSWORD=$pass "
$vArgs += "VMUM_SERVER_SELECT=$vCenter " 
​$vArgs += "VC_SERVER_IP=$vCenter "
$vArgs += "VC_SERVER_PORT=$port "
$vArgs += "VC_SERVER_ADMIN_USER=$vCAdmin "
$vArgs += "VC_SERVER_ADMIN_PASSWORD=$vCAdmin_Pass`""
$vars = @()
$vars += '/s'
$vars += '/w'
$vars += $vArgs

Start-Process -FilePath $VUMMedia\VMware-UpdateManager.exe -ArgumentList $vars
