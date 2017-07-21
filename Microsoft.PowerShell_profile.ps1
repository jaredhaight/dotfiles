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

function ConvertTo-Base64
{
    param(
        [Paramater(Mandatory=$True)]
        [string]$String
    )
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($String)
    $EncodedText = [Convert]::ToBase64String($Bytes)
    return $EncodedText
}

function ConvertFrom-Base64
{
    param(
        [Paramater(Mandatory=$True)]
        [string]$String
    )
    $DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($String))
    $DecodedText
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
    Write-Host ("[" + ($(Get-Date).toString("MM/dd/yyyy hh:mm:ss"))+ "]:[" + $([System.Environment]::UserName) + "]:[" + $(Get-Location).path + "]")
  }
  Write-Host ("PS>" ) -NoNewLine
  Return " "
}
