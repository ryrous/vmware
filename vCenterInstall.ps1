#Install vCenter Server unattended
$VCMedia = "D:\vCenter-Server"
$SVC_USER = "WIN_VCENTER6\vCenter"
$SVC_PASS = "VMware123"
$FQDN = "MGMT-VC6.contoso.com"
$VcIP = "10.144.99.16"

#Database Info
$TYPE = "external"
$DSN = "vCenter"
$USER = "vCenter"
$PASS = "VMware123"

$SSO_DOMAIN = "vsphere.local"
$SSO_PASS = "VMware123!"
$SSO_SITE ="MY_SITE"

# Install vCenter
Write-Host "Installing vCenter"
$vars = "/i `"$VCmedia\VMware-vCenter-Server.msi`" "
$vars += "/l*e `"c:\temp\vCenterinstall.txt`" /qr "
$vars += "LAUNCHED_BY_EXE=0 FQDN=`"$FQDN`" "
$vars += "INSTALL_TYPE=embedded "
$vars += "DB_TYPE=$Type DB_DSN=`"$DSN`" "
$vars += "DB_USER=`"$USER`" "
$vars += "DB_PASSWORD=`"$PASS`" "
$vars += "INFRA_NODE_ADDRESS=`"$vCIP`" "
$vars += "VC_SVC_USER=`"$SVC_USER`" "
$vars += "VC_SVC_PASSWORD=`"$SVC_PASS`" "
$vars += "SSO_DOMAIN=`"$SSO_DOMAIN`" "
$vars += "SSO_PASSWORD=`"$SSO_PASS`" "
$vars += "SSO_SITENAME=`"$SSO_SITE`" "

Start-Process msiexec -ArgumentList $vars –Wait
