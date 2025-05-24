Import-Module -Force "$PSScriptRoot\PowerShell\Modules\MyUtil"

if (-not (Test-IsProcessElevated)) {
  throw 'Run the script from an elevated PowerShell'
}

if (-not (Test-IsCommandAvailable winget)) {
  throw 'WinGet is required to continue; visit https://github.com/microsoft/winget-cli'
}

# https://github.com/microsoft/winget-cli
Write-Host '👉 Update WinGet' -ForegroundColor Blue
winget source update
winget upgrade winget
