function Install-MyNerdFont {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String] $Name,
    [Parameter()]
    [String] $Filter
  )
  $zipPath = "$env:TEMP\$Name.zip"
  $downloadPage = Invoke-WebRequest 'https://www.nerdfonts.com/font-downloads' -UseBasicParsing
  $downloadUrlPattern = "https:\/\/github.com\/ryanoasis\/nerd-fonts\/releases\/download\/(v\d+.\d+.\d+)\/$Name.zip"
  if ($downloadPage -match $downloadUrlPattern) {
    $downloadUrl = $matches[0]
    $version = $matches[1]
    $extractPath = "$env:TEMP\$Name-$version"
    if (-not ($downloadUrl)) {
      Write-Error "Failed to find the font."
      return;
    }

    Write-Host "Downloading..."
    Write-Host $downloadUrl -ForegroundColor DarkGray
    Invoke-WebRequest $downloadUrl -OutFile $zipPath
    if (-not (Test-Path $zipPath)) {
      Write-Error "Failed to download the font."
      return;
    }

    Write-Host "Extracting..."
    Write-Host $extractPath -ForegroundColor DarkGray
    Expand-Archive -Force $zipPath -DestinationPath $extractPath
    if (-not (Test-Path $extractPath)) {
      Write-Error "Failed to extract the font."
      return;
    }

    $fonts = Get-ChildItem $extractPath -Filter $Filter
    if ($fonts.Length -eq 0) {
      Write-Error "Cannot determine which font files to install. Please recheck the filter."
      return;
    }

    Write-Host 'Installing...'
    foreach ($font in $fonts) {
      Write-Host $font.Name -ForegroundColor DarkGray
      Copy-Item $font.FullName "$env:WINDIR\Fonts\$($font.Name)"

      $regKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
      $existingKey = Get-ItemProperty $font.BaseName -Path $regKey -ErrorAction SilentlyContinue

      if ($existingKey) {
        Set-ItemProperty $font.BaseName -Path $regKey -Value $font.Name
      }
      else {
        New-ItemProperty $font.BaseName -Path $regKey -Value $font.Name -PropertyType String | Out-Null
      }
    }

    Remove-Item $zipPath
    Remove-Item -r $extractPath
  }
}

function Remove-MyFont {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [String] $Filter
  )
  if ((-not $Filter) -or ($Filter.Length -lt 9)) {
    Write-Error 'Cannot delete all fonts. Either filter is missing or it is not very specific.'
    return;
  }
  $fonts = Get-ChildItem $env:WINDIR\Fonts -Filter $Filter
  if ($fonts.Length -eq 0) {
    Write-Error "No such fonts were installed. Please recheck the filter."
    return;
  }

  Write-Host 'Uninstalling...'
  foreach ($font in $fonts) {
    Write-Host $font.Name -ForegroundColor DarkGray
    Remove-Item $font

    $regKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
    $existingKey = Get-ItemProperty $font.BaseName -Path $regKey -ErrorAction SilentlyContinue

    if ($existingKey) {
      Remove-ItemProperty $font.BaseName -Path $regKey
    }
  }
}
