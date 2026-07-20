param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 2100000000)]
    [int]$BuildNumber,

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
    [string]$BuildDate = (Get-Date -Format 'yyyy-MM-dd')
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

function Update-TextFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Update
    )

    $text = Get-Content -LiteralPath $Path -Raw
    $updated = & $Update $text

    if ($updated -eq $text) {
        Write-Host "No changes needed: $Path"
        return
    }

    Set-Content -LiteralPath $Path -Value $updated -NoNewline
    Write-Host "Updated: $Path"
}

$pubspecPath = Join-Path $repoRoot 'pubspec.yaml'
$localPropertiesPath = Join-Path $repoRoot 'android/local.properties'
$appUtilsPath = Join-Path $repoRoot 'lib/utils/app_utils.dart'

if (-not (Test-Path -LiteralPath $pubspecPath)) {
    throw "pubspec.yaml was not found at $pubspecPath"
}

if (-not (Test-Path -LiteralPath $localPropertiesPath)) {
    throw "android/local.properties was not found at $localPropertiesPath"
}

if (-not (Test-Path -LiteralPath $appUtilsPath)) {
    throw "lib/utils/app_utils.dart was not found at $appUtilsPath"
}

$pubspecText = Get-Content -LiteralPath $pubspecPath -Raw
$versionMatch = [regex]::Match($pubspecText, '(?m)^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$')
if (-not $versionMatch.Success -and -not $BuildNumber) {
    throw 'Could not read the existing build number from pubspec.yaml. Pass -BuildNumber explicitly.'
}

if (-not $BuildNumber) {
    $BuildNumber = [int]$versionMatch.Groups[2].Value + 1
}

Update-TextFile -Path $pubspecPath -Update {
    param($text)
    [regex]::Replace($text, '(?m)^version:\s*\d+\.\d+\.\d+\+\d+\s*$', "version: $Version+$BuildNumber")
}

Update-TextFile -Path $localPropertiesPath -Update {
    param($text)
    $text = [regex]::Replace($text, '(?m)^flutter\.buildMode=.*$', 'flutter.buildMode=release')
    $text = [regex]::Replace($text, '(?m)^flutter\.versionName=.*$', "flutter.versionName=$Version")
    $text = [regex]::Replace($text, '(?m)^flutter\.versionCode=.*$', "flutter.versionCode=$BuildNumber")
    $text
}

Update-TextFile -Path $appUtilsPath -Update {
    param($text)
    # Updated regex to match the top-level const in lib/utils/app_utils.dart
    $text = [regex]::Replace($text, "const appVersion = '[^']+';", "const appVersion = '$Version';")
    $text = [regex]::Replace($text, "const appBuildNumber = '[^']+';", "const appBuildNumber = '$BuildNumber';")
    $text = [regex]::Replace($text, "const appBuildDate = '[^']+';", "const appBuildDate = '$BuildDate';")
    $text
}

Write-Host ''
Write-Host "Version metadata is ready:"
Write-Host "  Version:    $Version"
Write-Host "  Build:      $BuildNumber"
Write-Host "  Build date: $BuildDate"
