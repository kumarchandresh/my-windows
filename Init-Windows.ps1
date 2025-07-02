# https://stackoverflow.com/a/49481797
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [Text.UTF8Encoding]::new()
$PSModulePath = Join-Path $env:ProgramFiles "PowerShell\Modules"

Import-Module -Force "$PSScriptRoot\PowerShell\Modules\MyFont"
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
Install-MyWinGetPackage Microsoft.WindowsTerminal

# https://gitforwindows.org
Write-Host '👉 Install Git for Windows' -ForegroundColor Blue
Install-MyWinGetPackage -Scope Machine Git.Git; Restore-EnvPath

# https://github.com/junegunn/fzf
Write-Host '👉 Install "junegunn/fzf"' -ForegroundColor Magenta
Install-MyWinGetPackage junegunn.fzf

# https://github.com/ajeetdsouza/zoxide
Write-Host '👉 Install "ajeetdsouza/zoxide"' -ForegroundColor Magenta
Install-MyWinGetPackage ajeetdsouza.zoxide

# https://aka.ms/vscode
Write-Host '👉 Install Visual Studio Code' -ForegroundColor Blue
Install-MyWinGetPackage -Scope Machine Microsoft.VisualStudioCode

$psGalleryUri = (Get-PSResourceRepository PSGallery).Uri | Select-Object -ExpandProperty AbsoluteUri | Out-String
if ($psGalleryUri -match 'www\.powershellgallery\.com' -and (-not (Get-PSResourceRepository PSGallery).Trusted)) {
  Write-Host 'Set PSGallery as Trusted'
  Set-PSResourceRepository PSGallery -Trusted
}

# https://github.com/microsoft/winget-cli/tree/master/src/PowerShell/Microsoft.WinGet.Client
Write-Host '👉 Install Microsoft.WinGet.Client' -ForegroundColor Blue
Install-MyPSResource -Import Microsoft.WinGet.Client | Out-Host

# https://github.com/dahlbyk/posh-git
Write-Host '👉 Install posh-git' -ForegroundColor Blue
Install-MyPSResource -Import posh-git | Out-Host

# https://github.com/devblackops/Terminal-Icons
Write-Host '👉 Install Terminal-Icons' -ForegroundColor Blue
Install-MyPSResource -Import Terminal-Icons | Out-Host

# https://www.nerdfonts.com/font-downloads
Write-Host '👉 Install Cascadia Code Nerd font' -ForegroundColor Blue
Install-MyNerdFont CascadiaCode -Filter CaskaydiaCoveNerdFont-*.ttf

# https://github.com/catppuccin/powershell
Write-Host '👉 Install Catppuccin for PowerShell' -ForegroundColor Blue
Install-MyPSResourceFromGitHub -Uri "https://github.com/catppuccin/powershell/archive/refs/heads/main.zip" `
                               -OutFile "Catppuccin.zip" `
                               -Root "powershell-main" `
                               -Destination "$PSModulePath\Catppuccin" `

# https://github.com/catppuccin/windows-terminal
Write-Host '👉 Install Catppuccin for Windows Terminal' -ForegroundColor Blue
$windowsTerminalSettingsPath = "$PSScriptRoot\Settings\WindowsTerminal\settings.json"
$windowsTerminalSettings = Get-Content $windowsTerminalSettingsPath | ConvertFrom-Json -Depth 69
Write-Host "Downloading color schemes..."
$windowsTerminalSettings.schemes = @("frappe", "latte", "macchiato", "mocha") | ForEach-Object {
  Write-Host $_ -ForegroundColor DarkGray
  Invoke-WebRequest ("https://raw.githubusercontent.com/catppuccin/windows-terminal/refs/heads/main/$_" + ".json") |
  Select-Object -ExpandProperty Content |
  ConvertFrom-Json
}
Write-Host "Downloading themes..."
$windowsTerminalSettings.themes = @("frappe", "latte", "macchiato", "mocha") | ForEach-Object {
  Write-Host $_ -ForegroundColor DarkGray
  Invoke-WebRequest ("https://raw.githubusercontent.com/catppuccin/windows-terminal/refs/heads/main/$_" + "Theme.json") |
  Select-Object -ExpandProperty Content |
  ConvertFrom-Json
}
$windowsTerminalSettings | ConvertTo-Json -Depth 69 | Out-File $windowsTerminalSettingsPath

# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles
Write-Host '👉 Install PowerShell profile' -ForegroundColor Blue
$profileSourcePath = "$env:USERPROFILE\Documents\PowerShell"
$profileDestinationPath = "$PSScriptRoot\PowerShell"
if ((-not (Test-IsSymbolicLink $profileSourcePath)) -and (Test-IsDirectory $profileSourcePath)) {
  $profileBackupPath = "$profileSourcePath-$(Get-Date -Format 'yyyy.MM.dd-HH.mm.ss')"
  Write-Host "Backup directory: $profileBackupPath"
  Move-Item $profileSourcePath $profileBackupPath
}
if (Test-IsSymbolicLink $profileSourcePath) {
  Write-Host "Overwrite existing symlink: $profileDestinationPath" -ForegroundColor DarkGray
  (Get-Item $profileSourcePath).Delete()
}
else {
  Write-Host "Create new symlink: $profileDestinationPath" -ForegroundColor DarkGray
}
New-Item $profileSourcePath -ItemType SymbolicLink -Value $profileDestinationPath

# https://learn.microsoft.com/en-us/windows/terminal/install#configuration
Write-Host '👉 Install Windows Terminal settings' -ForegroundColor Blue
$termDir = Get-ChildItem "$env:LocalAppData\Packages" -Filter Microsoft.WindowsTerminal_* | Select-Object -First 1 -ExpandProperty FullName
$termConfigSourcePath = Join-Path $termDir 'LocalState\settings.json'
$termConfigDestinationPath = "$PSScriptRoot\Settings\WindowsTerminal\settings.json"
if ((-not (Test-IsSymbolicLink $termConfigSourcePath)) -and (Test-IsFile $termConfigSourcePath)) {
  $termConfigBackupPath = "$(Join-Path $termDir 'LocalState\settings')-$(Get-Date -Format 'yyyy.MM.dd-HH.mm.ss').json"
  Write-Host "Backup settings: $termConfigBackupPath"
  Move-Item $termConfigSourcePath $termConfigBackupPath
}
if (Test-IsSymbolicLink $termConfigSourcePath) {
  Write-Host "Overwrite existing symlink: $termConfigDestinationPath" -ForegroundColor DarkGray
  (Get-Item $termConfigSourcePath).Delete()
}
else {
  Write-Host "Create new symlink: $termConfigDestinationPath" -ForegroundColor DarkGray
}
New-Item $termConfigSourcePath -ItemType SymbolicLink -Value $termConfigDestinationPath
