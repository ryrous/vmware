Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -WarningAction SilentlyContinue
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm