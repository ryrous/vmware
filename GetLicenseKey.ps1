function Get-LicenseKey {
    <#
    .SYNOPSIS
    Retrieves License Key information
    .DESCRIPTION
    This function will list all license keys added to vCenter Server
    .NOTES
    Source:  Automating vSphere Administration
    .EXAMPLE
    Get-LicenseKey
    #>
    Process {
        $servInst = Get-View ServiceInstance
        $licMgr = Get-View $servInst.Content.licenseManager
        $licMgr.Licenses
    }
}
