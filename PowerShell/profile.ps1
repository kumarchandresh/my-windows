# https://stackoverflow.com/a/49481797
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$OutputEncoding = [Console]::OutputEncoding = [Console]::InputEncoding = [Text.UTF8Encoding]::new()

Import-Module -Force posh-git
Import-Module -Force PSFzf
Import-Module -Force ZLocation
Import-Module -Force Terminal-Icons

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

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
