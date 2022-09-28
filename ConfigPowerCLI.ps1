Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP -Confirm:$false
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -WarningAction SilentlyContinue -Confirm:$false
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false