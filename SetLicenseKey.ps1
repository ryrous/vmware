function Set-LicenseKey {
    <#
    .SYNOPSIS
    Sets a License Key for a host
    .DESCRIPTION
    This function will set a license key for a host which is attached to a vCenter Server
    .NOTES
    Source:  Automating vSphere Administration
    .PARAMETER LicKey
    The License Key
    .PARAMETER VMHost
    The vSphere host to add the license key to
    .PARAMETER Name
    The friendly name to give the license key
    .EXAMPLE
    Set-LicenseKey -LicKey "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE" -VMHost "esxhost01.contoso.com" -Name $null
    #>
    param(
        [String]$VMHost,
        [String]$LicKey,
        [String]$Name
    )
    Process {
        $vmhostId = (Get-VMHost $VMHost | Get-View –Property Config.Host).Config.Host.Value
        $servInst = Get-View ServiceInstance
        $licMgr = Get-View $servInst.Content.licenseManager
        $licAssignMgr = Get-View $licMgr.licenseAssignmentManager
        $license = New-Object VMware.Vim.LicenseManagerLicenseInfo
        $license.LicenseKey = $LicKey
        $licAssignMgr.UpdateAssignedLicense(`
        $VMHostId, $license.LicenseKey, $Name)
        $hostlicense = (get-vmhost $VMhost).LicenseKey
        Write-Host ("Host [$VMhost] license has been set to $hostlicense")
    }
}

Set-LicenseKey -LicKey "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE" -VMHost "esxhost01.contoso.com" -Name $null
