# https://stackoverflow.com/a/49481797
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [Text.UTF8Encoding]::new()

Import-Module -Force posh-git
Import-Module -Force PSFzf
Import-Module -Force ZLocation
Import-Module -Force Catppuccin
Import-Module -Force Terminal-Icons

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# https://github.com/catppuccin/powershell?tab=readme-ov-file#profile-usage
$Flavor = $Catppuccin['Frappe']
# The following colors are used by PowerShell's formatting
# Again PS 7.2+ only
$PSStyle.Formatting.Debug = $Flavor.Sky.Foreground()
$PSStyle.Formatting.Error = $Flavor.Red.Foreground()
$PSStyle.Formatting.ErrorAccent = $Flavor.Blue.Foreground()
$PSStyle.Formatting.FormatAccent = $Flavor.Teal.Foreground()
$PSStyle.Formatting.TableHeader = $Flavor.Rosewater.Foreground()
$PSStyle.Formatting.Verbose = $Flavor.Yellow.Foreground()
$PSStyle.Formatting.Warning = $Flavor.Peach.Foreground()
# Modified from the official Catppuccin fzf configuration at: https://github.com/catppuccin/fzf/
$env:FZF_DEFAULT_OPTS = @"
--color=bg+:$($Flavor.Surface0),bg:$($Flavor.Base),spinner:$($Flavor.Rosewater)
--color=hl:$($Flavor.Red),fg:$($Flavor.Text),header:$($Flavor.Red)
--color=info:$($Flavor.Mauve),pointer:$($Flavor.Rosewater),marker:$($Flavor.Rosewater)
--color=fg+:$($Flavor.Text),prompt:$($Flavor.Mauve),hl+:$($Flavor.Red)
--color=border:$($Flavor.Surface2)
"@

function which {
  (
    Get-Command $args -CommandType Application, ExternalScript -ErrorAction SilentlyContinue |
    Select-Object -First 1 -ExpandProperty Source
  ) -replace [Regex]::Escape($env:USERPROFILE), '~'
}

function clock {
  $clockEmojiMap = @{
    "🕛" =  0.0;    "🕧" =  0.5;
    "🕐" =  1.0;    "🕜" =  1.5;
    "🕑" =  2.0;    "🕝" =  2.5;
    "🕒" =  3.0;    "🕞" =  3.5;
    "🕓" =  4.0;    "🕟" =  4.5;
    "🕔" =  5.0;    "🕠" =  5.5;
    "🕕" =  6.0;    "🕡" =  6.5;
    "🕖" =  7.0;    "🕢" =  7.5;
    "🕗" =  8.0;    "🕣" =  8.5;
    "🕘" =  9.0;    "🕤" =  9.5;
    "🕙" = 10.0;    "🕥" = 10.5;
    "🕚" = 11.0;    "🕦" = 11.5;
  }
  $now = Get-Date
  $nowDecimal = ($now.Hour % 12) + ($now.Minute / 60.0)
  $nearest = $clockEmojiMap.GetEnumerator() | Sort-Object { [Math]::Abs($_.Value - $nowDecimal) } | Select-Object -First 1
  $clock = $nearest.Key
  $date = $now.ToString('M/d/yyyy')
  $time = $now.ToString('hh:mm:ss tt')
  "📅 $date $clock $time"
}

$GitPromptSettings.DefaultPromptSuffix = ' $(clock)`n$(if (Test-IsProcessElevated) { "#" } else { "$" }) '
