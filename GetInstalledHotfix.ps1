$script = @'
  $hotfix = "KB4012598", "KB4012598", "KB4012598", "KB4012598", "KB4012212", "KB4012215", "KB4012212", "KB4012215", "KB4012213", "KB4012216", "KB4012214", "KB4012217", "KB4012213", "KB4012216", "KB4012606", "KB4013198", "KB4013429", "KB4013429"
  $hotfixinfo = "No hotfix found!"
  $fixes = Get-WmiObject -Class "win32_quickfixengineering" | Where-Object {$hotfix -contains $_.HotFixID} | Select-Object -ExpandProperty HotFixID

  if($fixes){
    $hotfixinfo = "$($fixes -join ',') installed"
  }
  $hotfixinfo
'@

$accounts = @(
   @{
    User = 'administrator'
    Pswd = 'pswd1'
   },

   @{
    User = 'administrator'
    Pswd = 'pswd2'
   },

   @{
    User = 'administrator'
    Pswd = 'pswd3'
   },

   @{
    User = 'admin'
    Pswd = 'pswd4'
   }
)

Get-ResourcePool -Name 'testpool' -PipelineVariable rp | ForEach-Object -Process {
  Get-VM -Location $rp -PipelineVariable vm | ForEach-Object -Process {
    $out = 'Login failed'
    foreach ($user in $accounts) {
      try {
        $sInvoke = @{
          VM = $vm
          GuestUser = $user.User
          GuestPassword = $user.Pswd
          ScriptText = $script
          ScriptType = 'Powershell'
          ErrorAction = 'Stop'
        }
        $out = Invoke-VMScript @sInvoke | Select-Object -ExpandProperty ScriptOutput
        break
      } catch {

      }
    }
    New-Object PSObject -Property (
      [ordered]@{
        Name = $vm.Name
        OS = $vm.Guest.OSFullName
        IP = $vm.Guest.IPAddress -join '|'
        RP = $rp.Name
        Result = $out
      }
    )
  }
} | Export-Csv -Path .\Output.csv -NoTypeInformation -NoClobber