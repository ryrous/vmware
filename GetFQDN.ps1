Get-VM | Select-Object Name, @{N='FQDN';E={$_.ExtensionData.Guest.IPStack[0].DnsConfig.HostName,$_.ExtensionData.Guest.IPStack[0].DnsConfig.DomainName -join '.'}}
