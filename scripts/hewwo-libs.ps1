param(
    [Parameter(Mandatory)][string]$Root,
    [Parameter(Mandatory)][ValidateSet('Setup','Check')][string]$Mode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RootFull = [IO.Path]::GetFullPath($Root)
$LibsDir = Join-Path $RootFull 'libs'
$AceCanonFull = Join-Path ([IO.Path]::GetFullPath((Join-Path $RootFull '..'))) 'Ace3'
$iconCanonFull = Join-Path ([IO.Path]::GetFullPath((Join-Path $RootFull '..'))) 'LibDBIcon-1.0'

$aceAceAddon = Join-Path $LibsDir 'Ace3/AceAddon-3.0/AceAddon-3.0.lua'
$iconEmbeds = Join-Path $LibsDir 'LibDBIcon-1.0/embeds.xml'

function Get-CanonicalPath([string]$p) {
    return ([IO.Path]::GetFullPath($p)).TrimEnd('\')
}

function Assert-CanonPresent {
    param([string]$Path, [string]$Hint)

    if (-not (Test-Path -LiteralPath $Path)) {
        $msg = 'Missing expected folder:' + [Environment]::NewLine + '  ' + $Path + [Environment]::NewLine + $Hint
        Write-Error $msg
        exit 1
    }
}

function Resolve-LinkTargetFull {
    param(
        [string]$LinkPath,
        $RawTarget,
        [string]$LinkDirectory
    )
    $t = @($RawTarget)[0]
    if ([string]::IsNullOrWhiteSpace($t)) {
        throw "Could not resolve target for symlink: $LinkPath"
    }
    if ([IO.Path]::IsPathRooted($t)) {
        return (Get-CanonicalPath $t)
    }
    return (Get-CanonicalPath (Join-Path $LinkDirectory $t))
}

function Initialize-LibSymlink {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$RelativeTargetFromLibs,
        [Parameter(Mandatory)][string]$ExpectedCanonFullPath
    )

    $ExpectedCanonNormalized = Get-CanonicalPath $ExpectedCanonFullPath
    $linkFull = Join-Path $LibsDir $Name

    if (-not (Test-Path -LiteralPath $LibsDir)) {
        $msg = 'libs folder not found; run Setup first.' + [Environment]::NewLine + 'Missing: ' + $LibsDir
        Write-Error $msg
        exit 1
    }

    $item = Get-Item -LiteralPath $linkFull -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) {
        New-Item -ItemType SymbolicLink -Path $linkFull -Target $RelativeTargetFromLibs | Out-Null
        Write-Host "Created symlink: $linkFull -> $RelativeTargetFromLibs"
        return
    }

    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        try {
            $resolved = Resolve-LinkTargetFull $linkFull $item.Target $LibsDir
        } catch {
            Write-Host "Stale or unreadable symlink; replacing: $Name"
            Remove-Item -LiteralPath $linkFull -Force -Recurse
            New-Item -ItemType SymbolicLink -Path $linkFull -Target $RelativeTargetFromLibs | Out-Null
            Write-Host "Symlink recreated: $linkFull -> $RelativeTargetFromLibs"
            return
        }

        if ($resolved -eq $ExpectedCanonNormalized) {
            Write-Host "OK: $Name -> $RelativeTargetFromLibs"
            return
        }

        Write-Host "Replacing incorrect symlink: $Name"
        Remove-Item -LiteralPath $linkFull -Force -Recurse
        New-Item -ItemType SymbolicLink -Path $linkFull -Target $RelativeTargetFromLibs | Out-Null
        Write-Host "Created symlink: $linkFull -> $RelativeTargetFromLibs"
        return
    }

    $err = $linkFull + ' exists and is not a symlink. Remove or rename it, then re-run just setup.'
    Write-Error $err
    exit 1
}

if ($Mode -eq 'Check') {
    $missing = @()
    if (-not (Test-Path -LiteralPath $aceAceAddon)) { $missing += $aceAceAddon }
    if (-not (Test-Path -LiteralPath $iconEmbeds)) { $missing += $iconEmbeds }
    if ($missing.Count -gt 0) {
        $bulletLines = @( $missing | ForEach-Object { '- ' + $_ }) -join [Environment]::NewLine
        Write-Error ('check failed; missing:' + [Environment]::NewLine + $bulletLines)
        exit 1
    }
    Write-Host 'check: OK'
    exit 0
}

Assert-CanonPresent $AceCanonFull 'Install Ace3 under _retail_\Interface\AddOns\Ace3'
Assert-CanonPresent $iconCanonFull 'Install LibDBIcon-1.0 under _retail_\Interface\AddOns\LibDBIcon-1.0'

New-Item -ItemType Directory -Path $LibsDir -Force | Out-Null

Initialize-LibSymlink -Name 'Ace3' -RelativeTargetFromLibs '..\..\Ace3' -ExpectedCanonFullPath $AceCanonFull
Initialize-LibSymlink -Name 'LibDBIcon-1.0' -RelativeTargetFromLibs '..\..\LibDBIcon-1.0' -ExpectedCanonFullPath $iconCanonFull

Write-Host 'setup: complete'
