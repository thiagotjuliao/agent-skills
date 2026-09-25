#Requires -Version 7
<#
.SYNOPSIS
  Installs the skills in this repository for Claude Code.

.EXAMPLE
  ./install-claude.ps1
  ./install-claude.ps1 project-tooling -Update
  ./install-claude.ps1 -Check

.NOTES
  The bash twin is install-claude.sh, and its header explains the model: a
  missing skill is installed, one that differs is reported with its diff and
  only replaced under -Update, and skills installed from anywhere else are
  never touched. The destination is ~/.claude/skills, or
  $env:CLAUDE_CONFIG_DIR/skills when that is set.
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0, ValueFromRemainingArguments)][string[]]$Skill,
  [switch]$Update,
  [switch]$Check
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$configDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$dest = Join-Path $configDir 'skills'

if (-not $Skill) { $Skill = (Get-ChildItem (Join-Path $here 'skills') -Directory).Name }

# Every file of a tree, relative, with its content LF-normalised: line endings
# are the checkout's business, not a difference.
function Get-TreeText([string]$Root) {
  Get-ChildItem $Root -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
    $rel = [IO.Path]::GetRelativePath($Root, $_.FullName) -replace '\\', '/'
    "== $rel`n" + ((Get-Content $_.FullName -Raw) -replace "`r`n", "`n")
  }
}

function Show-Diff([string]$Old, [string]$New) {
  git --no-pager diff --no-index --color=never $Old $New 2>$null | ForEach-Object { "      $_" } | Out-Host
}

$installed = 0; $same = 0; $updated = 0; $drift = 0
Write-Host "skills -> $dest"
foreach ($name in $Skill) {
  $src = Join-Path $here 'skills' $name
  if (-not (Test-Path (Join-Path $src 'SKILL.md'))) { throw "no such skill: $name" }
  $dst = Join-Path $dest $name

  if (-not (Test-Path $dst)) {
    if ($Check) { Write-Host "  missing   $name"; $drift++ }
    else {
      New-Item -ItemType Directory -Force -Path $dest | Out-Null
      Copy-Item $src $dst -Recurse
      Write-Host "  installed $name"; $installed++
    }
  }
  elseif (((Get-TreeText $src) -join "`n") -eq ((Get-TreeText $dst) -join "`n")) {
    Write-Host "  same      $name"; $same++
  }
  elseif ($Update -and -not $Check) {
    Show-Diff $dst $src
    Remove-Item $dst -Recurse -Force
    Copy-Item $src $dst -Recurse
    Write-Host "  updated   $name"; $updated++
  }
  else {
    Write-Host "  DIFFERS   $name"; $drift++
    Show-Diff $dst $src
  }
}

Write-Host ''
Write-Host "installed $installed, updated $updated, same $same, differs/missing $drift"
if ($drift -gt 0) {
  if ($Check) { exit 1 }
  Write-Host 'run again with -Update to replace the installed copies shown above'
}
