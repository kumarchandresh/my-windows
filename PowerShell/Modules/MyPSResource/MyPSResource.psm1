function Install-MyPSResource {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position = 0)]
    [String] $Name,
    [Parameter()]
    [String] $Repository = 'PSGallery',
    [Parameter()]
    [Switch] $Import
  )
  if (Get-InstalledPSResource -Scope AllUsers $Name -ErrorAction SilentlyContinue) {
    Write-Host 'Updating...' -ForegroundColor DarkGray
    Update-PSResource -Repository $Repository -TrustRepository -Scope AllUsers $Name
  }
  else {
    Write-Host 'Installing...' -ForegroundColor DarkGray
    Install-PSResource -Repository $Repository -TrustRepository -Scope AllUsers $Name
  }
  if ($Import) {
    Import-Module $Name -PassThru
  }
}