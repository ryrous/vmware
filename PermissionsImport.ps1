function Import-Permissions {
    <#
    .SYNOPSIS
    Imports all Permissions from CSV file 
    .DESCRIPTION
    The function will import all permissions from a CSV file and apply them to the vCenter Server objects.
    .NOTES
    Source:  Automating vSphere Administration
    .PARAMETER Filename
    The path of the CSV file to be imported
    .EXAMPLE
    Import-Permissions -DC -Filename "C:\Temp\Permissions.csv"
    #>
    param(
        [String]$Filename
    )
    process {
        $permissions = @()
        $permissions = Import-Csv $Filename
        foreach ($perm in $permissions) {
            $entity = (Get-View –Id $perm.EntityId –Property Name).MoRef
            $object = Get-Inventory -Name $perm.Name
            if ($object.Count){
                $object = $object | Where-Object {$_.Id -eq $perm.EntityId}
            }
            if ($object){
                switch -Wildcard ($perm.EntityId){
                    Folder* {
                        $entity.Type = "Folder"
                        $entity.value = $object.Id.TrimStart("Folder-")
                    }
                    VirtualMachine* {
                        $entity.Type = "VirtualMachine"
                        $entity.value = $object.Id.TrimStart("VirtualMachine-")
                    }
                    ClusterComputeResource* {
                        $entity.Type = "ClusterComputeResource"
                        $entity.value = `
                    ​    $object.Id.TrimStart("ClusterComputeResource-")
                    }
                    Datacenter* {
                        $entity.Type = "Datacenter"
                        $entity.value = $object.Id.TrimStart("Datacenter-")
                    }
                }
                $setperm = New-Object VMware.Vim.Permission
                $setperm.principal = $perm.Principal
                if ($perm.isgroup -eq "True") {
                    $setperm.group = $true
                } 
                else {
                    $setperm.group = $false
                }
                $setperm.roleId = (Get-VIRole $perm.Role).id
                if ($perm.propagate -eq "True") {
                    $setperm.propagate = $true
                } 
                else {
                    $setperm.propagate = $false
                }
                $AuthMan = Get-View -Id 'AuthorizationManager-AuthorizationManager'
                Write-Host "Setting Permissions on $($perm.Name) for $($perm.principal)"
                $AuthMan.SetEntityPermissions($entity, $setperm)
            }
        }
    }
}

Import-Permissions -DC "DC01" -Filename "C:\Temp\Permissions.csv"
