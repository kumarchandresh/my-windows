Import-Module "$PSScriptRoot\..\MyUtil"

function Get-MyWinGetPackages {
  (winget list) -match '^\p{L}' | ConvertFrom-FixedColumnTable
}
function Get-MyWinGetPackage {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [String] $Id
  )
  if ((Get-Command Get-InstalledPSResource -ErrorAction SilentlyContinue) -and (
    Get-InstalledPSResource -Scope AllUsers Microsoft.WinGet.Client -ErrorAction SilentlyContinue)) {
    Get-WinGetPackage -Id $Id
  }
  else {
    Get-MyWinGetPackages | Where-Object -Property Id -eq $Id
  }
}

function Install-MyWinGetPackage {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [String] $Id,
    [Parameter()]
    [ValidateSet('Machine', 'User')]
    [String] $Scope,
    [Parameter()]
    [ValidateSet('WinGet', 'MSStore')]
    [String] $Source = 'WinGet'
  )
  $cb = @('winget')
  $cb += @(if (Get-MyWinGetPackage $Id) { 'upgrade' } else { 'install' })
  $cb += @('--exact --id', $Id)
  if ($Scope)  { $cb += @('--scope',  $Scope.ToLower())  }
  if ($Source) { $cb += @('--source', $Source.ToLower()) }
  $pkgType = '~'
  $pkgInfo = winget show --exact --id $Id | Out-String
  if ($pkgInfo -match 'Installer Type:\s+(.+)') {
    $pkgType = $matches[1].Trim()
  }
  if ($pkgType -eq 'wix') {
    $pkgOpt = "$PSScriptRoot\Option\$Id.txt"
    if (Test-Path $pkgOpt) { $cb += @(                 "--custom '$(Get-Content $pkgOpt)'") }
    else                   { $cb += @('--interactive', "--custom '/log install.log'") }
  }
  $cmd = $cb -join ' '
  Write-Host "$(Get-DefaultPrompt)$cmd" -ForegroundColor DarkGray
  Invoke-Expression $cmd
}