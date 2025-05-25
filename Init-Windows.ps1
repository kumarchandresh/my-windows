Import-Module -Force "$PSScriptRoot\PowerShell\Modules\MyPSResource"
Import-Module -Force "$PSScriptRoot\PowerShell\Modules\MyUtil"
Import-Module -Force "$PSScriptRoot\PowerShell\Modules\MyWinGet"

if (($PSEdition -eq 'Core') -and (-not $env:SelfExecute)) {
  throw 'Should be executed from Windows PowerShell only'
}

if (-not (Test-IsProcessElevated)) {
  throw 'Run the script from an elevated Windows PowerShell'
}

if (-not (Test-IsCommandAvailable winget)) {
  throw 'WinGet is required to continue; visit https://github.com/microsoft/winget-cli'
}

if (-not $env:SelfExecute) {

# https://github.com/microsoft/winget-cli
Write-Host '👉 Update WinGet' -ForegroundColor Blue
winget source update
winget upgrade winget

}

if ($PSEdition -ne 'Core') {

# http://aka.ms/powershell
Write-Host '👉 Install PowerShell' -ForegroundColor Blue
Install-MyWinGetPackage Microsoft.PowerShell; Restore-EnvPath

pwsh -Command ('$env:SelfExecute = $True;' + "& '$PSCommandPath'")
return

}

# https://github.com/microsoft/winget-cli/tree/master/src/PowerShell/Microsoft.WinGet.Client
Write-Host '👉 Install Microsoft.WinGet.Client' -ForegroundColor Blue
Install-MyPSResource -Import Microsoft.WinGet.Client | Out-Host

echo "To be continued..."