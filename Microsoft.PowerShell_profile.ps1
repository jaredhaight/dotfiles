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

# From: https://adsecurity.org/?p=478
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

# From: https://blogs.msdn.microsoft.com/luc/2011/01/21/powershell-getting-the-hash-value-for-a-string/
function Get-StringHash
{
    param(
        [string]$String,
        [string]$Hash="SHA256"
    )

    $hasher = switch ($Hash){
        "SHA512" {new-object System.Security.Cryptography.SHA512Managed}
        "SHA256" {new-object System.Security.Cryptography.SHA256Managed}
        "SHA1" {new-object System.Security.Cryptography.SHA1Managed}
        "MD5" {new-object System.Security.Cryptography.MD5CryptoServiceProvider}
    }

    $toHash = [System.Text.Encoding]::UTF8.GetBytes($string)
    $hashByteArray = $hasher.ComputeHash($toHash)
    foreach($byte in $hashByteArray)
    {
        $res += $byte.ToString("x2")
    }
    return $res;
}

function prompt 
{  
  $prompt_text = "PS>"
  Write-Host ""
  Write-Host ("[" + ($(Get-Date).toString("MM/dd/yyyy hh:mm:ss"))+ "] [" + $(Get-Location).path + "]")
  if (Test-Administrator) 
  {
    Write-Host -ForegroundColor Red "[ADMIN]" -NoNewline
    $prompt_text = " PS#"
  }
  Write-Host $prompt_text -NoNewLine
  Return " "
}
