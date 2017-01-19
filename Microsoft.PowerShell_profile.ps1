if ((Test-Path "C:\pslogs") -eq $False) {
	New-Item C:\PSLogs -Type Directory -Force | Out-Null
}
Start-Transcript "C:\pslogs\powershell_$([Environment]::UserName)_$($(Get-Date).ToString(`"MMddyyyy`")).log" -Append -NoClobber

function Test-Administrator
{  
   $user = [Security.Principal.WindowsIdentity]::GetCurrent();
   $role = [Security.Principal.WindowsBuiltinRole]::Administrator
   (New-Object Security.Principal.WindowsPrincipal $user).IsInRole($role)  
}

function prompt 
{
  Write-Host ""
  if (Test-Administrator) 
  {
    Write-Host ("[" + ($(Get-Date).toString("MM/dd/yyyy hh:mm:ss"))+ "]:[" + $([System.Environment]::UserName) + "(Admin)]")
  }
  else 
  {
    Write-Host ("[" + ($(Get-Date).toString("MM/dd/yyyy hh:mm:ss"))+ "]:[" + $([System.Environment]::UserName) + "]")
  }
  Write-Host ("PS " + $(Get-Location).path + ">" ) -NoNewLine
  Return " "
}