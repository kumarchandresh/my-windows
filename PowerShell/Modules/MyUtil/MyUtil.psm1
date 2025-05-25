function Test-IsProcessElevated {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]$identity
  $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsCommandAvailable {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [String] $Name
  )
  [Boolean](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-IsSymbolicLink {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $Path
    )
    [Boolean]((Test-Path $Path) -and (Get-ItemProperty $Path).LinkType)
}

function Test-IsDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $Path
    )
    Test-Path -Path $Path -PathType Container
}

function Test-IsFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String] $Path
    )
    Test-Path -Path $Path -PathType Leaf
}

function Restore-EnvPath {
  $env:Path = @(
    [Environment]::GetEnvironmentVariable('Path', 'Machine'),
    [Environment]::GetEnvironmentVariable('Path', 'User')
  ) -join ';'
}

# Built-in, default PowerShell prompt
function Get-DefaultPrompt {
  "PS $($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
}

<#
 # https://stackoverflow.com/a/74297741
 #  * Accepts input only via the pipeline, either line by line, or as a single, multi-line string.
 #  * The input is assumed to have a header line whose column names mark the start of each field
 #    * Column names are assumed to be *single words* (must not contain spaces).
 #  * The header line is assumed to be followed by a separator line (its format doesn't matter).
 #>
function ConvertFrom-FixedColumnTable {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] [String] $InputObject
    )

    begin {
        Set-StrictMode -Version 1
        $lineIdx = 0
    }

    process {

        $lines =
        if ($InputObject.Contains("`n")) { $InputObject -split '\r?\n' }
        else { $InputObject }
        foreach ($line in $lines) {
            ++$lineIdx
            if ($lineIdx -eq 1) {
                # header line
                $headerLine = $line
                # Get the indices where the fields start.
                $fieldStartIndices = [Regex]::Matches($headerLine, '\b\S').Index
                # Calculate the field lengths.
                $fieldLengths = foreach ($i in 1..($fieldStartIndices.Count - 1)) {
                    $fieldStartIndices[$i] - $fieldStartIndices[$i - 1] - 1
                }
                # Get the column names
                $colNames = foreach ($i in 0..($fieldStartIndices.Count - 1)) {
                    if ($i -eq $fieldStartIndices.Count - 1) {
                        $headerLine.Substring($fieldStartIndices[$i]).Trim()
                    }
                    else {
                        $headerLine.Substring($fieldStartIndices[$i], $fieldLengths[$i]).Trim()
                    }
                }
            }
            else {
                # data line
                $oht = [Ordered] @{} # ordered helper hashtable for object constructions.
                $i = 0
                foreach ($colName in $colNames) {
                    $oht[$colName] =
                    if ($fieldStartIndices[$i] -lt $line.Length) {
                        if ($fieldLengths[$i] -and $fieldStartIndices[$i] + $fieldLengths[$i] -le $line.Length) {
                            $line.Substring($fieldStartIndices[$i], $fieldLengths[$i]).Trim()
                        }
                        else {
                            $line.Substring($fieldStartIndices[$i]).Trim()
                        }
                    }
                    ++$i
                }
                # Convert the helper hashable to an object and output it.
                [PSCustomObject] $oht
            }
        }
    }

}