function Add-SSHKeys {
  ssh-add -K ~/.ssh/id_ed25519_v2
}

function Test-Administrator {
  if ($PSVersionTable.Platform -eq 'Win32NT' -or $null -eq $PSVersionTable.Platform) {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    $role = [Security.Principal.WindowsBuiltinRole]::Administrator
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole($role)  
  }
}

function New-RandomString {
  param (
    $Length = 8,
    [switch]
    $Lower = $false,
    [switch]
    $Upper = $false,
    [switch]
    $Number = $false,
    [switch]
    $Special = $false,
    [switch]
    $All = $false
  )
  if ($Lower -or $All -or -not ($Upper -or $Number -or $Special)) {
    $range = (97..122)
  }

  if ($Upper -or $All) {
    $range = $range + (65..90)
  }

  if ($Number -or $All) {
    $range = $range + (48..57)
  }

  if ($Special -or $All) {
    $range = $range + (33..47)
  }

  return -join ($range | Get-Random -Count $Length | ForEach-Object {[char]$_})
}

# From: https://adsecurity.org/?p=478
function ConvertTo-Base64 {
  param(
    [Parameter(Mandatory = $True)]
    [string]$String
  )
  $Bytes = [System.Text.Encoding]::Unicode.GetBytes($String)
  $EncodedText = [Convert]::ToBase64String($Bytes)
  return $EncodedText
}

function ConvertFrom-Base64 {
  param(
    [Parameter(Mandatory = $True)]
    [string]$String
  )
  $DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($String))
  $DecodedText
}

# From: https://blogs.msdn.microsoft.com/luc/2011/01/21/powershell-getting-the-hash-value-for-a-string/
function Get-StringHash {
  param(
    [string]$String,
    [string]$Hash = "SHA256"
  )

  $hasher = switch ($Hash) {
    "SHA512" { new-object System.Security.Cryptography.SHA512Managed }
    "SHA256" { new-object System.Security.Cryptography.SHA256Managed }
    "SHA1" { new-object System.Security.Cryptography.SHA1Managed }
    "MD5" { new-object System.Security.Cryptography.MD5CryptoServiceProvider }
  }

  $toHash = [System.Text.Encoding]::UTF8.GetBytes($string)
  $hashByteArray = $hasher.ComputeHash($toHash)
  foreach ($byte in $hashByteArray) {
    $res += $byte.ToString("x2")
  }
  return $res;
}

function Get-ExternalIPAddress {
  return (New-Object Net.WebClient).DownloadString('http://ifconfig.io/ip').Replace("`n", "")
}

function ConvertTo-ShortPath ($path) {
  $seperator = $path.Provider.ItemSeparator
  $drive = $path.Drive.Root
  $pathString = $path.ToString()

  $lastSlash = $pathString.LastIndexOf($seperator)
  $secondToLastSlash = $pathString.LastIndexOf($seperator, $lastSlash - 1)
  $thirdToLastSlash = $pathString.LastIndexOf($seperator, $secondToLastSlash - 1)
  $tail = $pathString.Substring($thirdToLastSlash)
  $shortPath = "$drive..$tail"
  $shortPath
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

function Test-GitRepo {
  [CmdletBinding()]
  param (
      [Parameter()]
      $Path
  )
  $currentDir = Get-Location
  Write-Verbose "Current Dir: $currentDir"
  $isGitDir = Test-Path $(Join-Path $currentDir ".git")
  $index = 0
  $parentDir = Split-Path $currentDir -Parent
  Write-Verbose "$index - $parentDir - Git Repo? $isGitDir"
  while ((![string]::IsNullOrEmpty($parentDir) -and ($isGitDir -eq $false))) {
    $gitPath = Join-Path $parentDir ".git"
    $isGitDir = Test-Path $gitPath
    $parentDir = Split-Path $parentDir -Parent
    $index += 1
    Write-Verbose "$index - $parentDir - Git Repo? $isGitDir"
  }
  $isGitDir
}

# Check if git is installed
try {
  Get-Command git -ErrorAction Stop | Out-Null
  $gitInstalled = $true
}
catch {
  $gitInstalled = $false
}

function prompt { 
  Write-Host ""

  $currentDir = Get-Location
  if ($currentDir.Path.Length -gt 55) {
    $currentDir = ConvertTo-ShortPath $currentDir
  }
  
  Write-Host ("[" + ($(Get-Date).toString("MM/dd/yyyy hh:mm:ss")) + "] [" + $currentDir + "]") -NoNewline
  
  # Check if we're in a git repo
  if ($gitInstalled -and (Test-GitRepo)) {
    $output = &git status 2>&1
    if ($output.GetType() -ne [System.Management.Automation.ErrorRecord]) {
      $branch = $output[0].Replace('On branch ', '')
      if ($output[3] -like '*clean') {
        Write-Host -NoNewline -ForegroundColor Green " [$branch]"
      }
      else {
        Write-Host -NoNewLine -ForegroundColor Red " [$branch]"
      }
    }
  }

  # New line after the status stuff ([TIME] [DIRECTORY] [GIT BRANCH])
  Write-Host ""
  
  # Determine our prompt, either `PS>` or `[ADMIN] PS#`
  $prompt_text = "PS>"
  if (Test-Administrator) {
    Write-Host -ForegroundColor Red "[ADMIN]" -NoNewline
    $prompt_text = "PS#"
  }

  # Print prompt
  Write-Host $prompt_text -NoNewLine
  Return " "
}

# Add-SSHKeys
