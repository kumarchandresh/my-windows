function Test-IsProcessElevated {
  $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [System.Security.Principal.WindowsPrincipal]$identity
  $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsCommandAvailable {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [String] $Name
  )
  [Boolean](Get-Command $Name -ErrorAction SilentlyContinue)
}