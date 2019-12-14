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
        [Parameter(Mandatory=$True)]
        [string]$String
    )
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($String)
    $EncodedText = [Convert]::ToBase64String($Bytes)
    return $EncodedText
}

function ConvertFrom-Base64
{
    param(
        [Parameter(Mandatory=$True)]
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

function Get-ExternalIPAddress {
  return (New-Object Net.WebClient).DownloadString('http://ifconfig.io/ip').Replace("`n","")
}

function Split-String {
  param (
    [Parameter(Mandatory = $true)]
    [string]$String,
    [int]$MinLength = 50,
    [int]$MaxLength = 120,
    [string]$VariableName = "data",
    [ValidateSet("PowerShell", "CSharp")]
    $Format = "PowerShell"
  )

  $index = 0
  $length = $String.length

  if ($Format -eq "CSharp") {
    Write-Output "string $VariableName = `"`";"
  }

  while ($index -lt $length) {
    $substringSize = Get-Random -Minimum $MinLength -Maximum $MaxLength
    if (($index + $substringSize) -gt $length) {
      $substringSize = $length - $index
    }
    $subString = $string.substring($index, $substringSize)
    if ($Format -eq "PowerShell") {
      Write-Output "`$$VariableName += `"$subString`""
    }
    if ($Format -eq "CSharp") {
      Write-Output "$VariableName += `"$subString`";"
    }
    $index += $substringSize
  }
}
try {
  Get-Command git.exe -ErrorAction Stop
  $gitInstalled = $true
}
catch {
  $gitInstalled = $false
}

function prompt { 
  Write-Host "" 
  Write-Host ("[" + ($(Get-Date).toString("MM/dd/yyyy hh:mm:ss")) + "] [" + $(Get-Location).path + "]") -NoNewline
  
  # Check if we're in a git repo
  if ($gitInstalled -and (Test-Path $(Join-Path $pwd ".git"))) {
    $output = &git status
    $branch = $output[0].Replace('On branch ', '')
    if ($output[1] -like '*clean') {
      Write-Host -NoNewline -ForegroundColor Green " [$branch]"
    }
    else {
      Write-Host -NoNewLine -ForegroundColor Red " [$branch]"
    }
  }
  Write-Host ""
  
  $prompt_text = "PS>"
  if (Test-Administrator) {
    Write-Host -ForegroundColor Red "[ADMIN]" -NoNewline
    $prompt_text = " PS#"
  }
  Write-Host $prompt_text -NoNewLine
  Return " "
}
