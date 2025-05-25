# https://stackoverflow.com/a/49481797
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [Text.UTF8Encoding]::new()

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

pwsh -NoProfile -Command ('$env:SelfExecute = $True;' + "& '$PSCommandPath'")
return

}

# https://github.com/microsoft/terminal
Write-Host '👉 Install Windows Terminal' -ForegroundColor Blue
Install-MyWinGetPackage -Id Microsoft.WindowsTerminal

# https://gitforwindows.org/
Write-Host '👉 Install Git for Windows' -ForegroundColor Blue
Install-MyWinGetPackage -Scope Machine Git.Git; Restore-EnvPath

# https://github.com/microsoft/winget-cli/tree/master/src/PowerShell/Microsoft.WinGet.Client
Write-Host '👉 Install Microsoft.WinGet.Client' -ForegroundColor Blue
Install-MyPSResource -Import Microsoft.WinGet.Client | Out-Host

# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles
Write-Host '👉 Install PowerShell profile' -ForegroundColor Blue
$profileSourcePath = "$env:USERPROFILE\Documents\PowerShell"
$profileDestinationPath = "$PSScriptRoot\PowerShell"
if ((-not (Test-IsSymbolicLink $profileSourcePath)) -and (Test-IsDirectory $profileSourcePath)) {
  $profileBackupPath = "$profileSourcePath-$(Get-Date -Format 'yyyy.MM.dd')"
  Write-Host "Backup directory: $profileBackupPath"
  Move-Item $profileSourcePath $profileBackupPath
}
if (Test-IsSymbolicLink $profileSourcePath) {
  Write-Host "Overwrite exising symlink: $profileDestinationPath" -ForegroundColor DarkGray
  (Get-Item $profileSourcePath).Delete()
}
else {
  Write-Host "Create new symlink: $profileDestinationPath" -ForegroundColor DarkGray
}
New-Item $profileSourcePath -ItemType SymbolicLink -Value $profileDestinationPath

echo "To be continued..."