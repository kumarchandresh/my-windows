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
    Import-Module -Force $Name -PassThru
  }
}

function Install-MyPSResourceFromGitHub {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory, Position = 0)]
    [String] $Uri,
    [Parameter(Mandatory)]
    [String] $OutFile,
    [Parameter()]
    [String] $Root = ".",
    [Parameter(Mandatory)]
    [String] $Destination
  )
  if (-not (Split-Path $OutFile -IsAbsolute)) {
    $OutFile = Join-Path "$env:TEMP" $OutFile
  }
  $extractPath = Join-Path "$(Split-Path $OutFile -Parent)" "$(Split-Path $OutFile -LeafBase)"
  @($OutFile, $extractPath, $Destination) | ForEach-Object {
    if (Test-Path $_) { Remove-Item -r $_ }
  }
  Write-Host "Downloading..."
  Write-Host "$Uri -> $OutFile" -ForegroundColor DarkGray
  Invoke-WebRequest -Uri $Uri -UseBasicParsing -OutFile $OutFile
  Write-Host "Extracting..."
  Write-Host "$OutFile -> $extractPath" -ForegroundColor DarkGray
  Expand-Archive $OutFile -DestinationPath $extractPath
  $archiveRoot = Join-Path $extractPath $Root | Resolve-Path
  Write-Host "Copying..."
  Write-Host "$archiveRoot -> $Destination" -ForegroundColor DarkGray
  Copy-Item -Recurse $archiveRoot -Destination $Destination
}
