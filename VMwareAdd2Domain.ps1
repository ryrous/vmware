$JoinNewDomain = '$DomainUser = "domain\user";
                  $DomainPWord = ConvertTo-SecureString -String "Password" -AsPlainText -Force;
                  $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord;
                  Add-Computer -DomainName domain.com -Credential $DomainCredential;
                  Start-Sleep -Seconds 20;
                  Shutdown /r /t 0'
$vmList = Import-Csv .\ServerNames.csv -Header OldName, NewName
Foreach ($vmName in $vmList) {
    Invoke-VMScript -VM $vmName.Oldname -ScriptType PowerShell -ScriptText $JoinNewDomain -GuestUser Administrator -GuestPassword Password 
}
