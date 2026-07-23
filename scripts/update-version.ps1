param(
    [Parameter(Mandatory = $false)]
    [switch]$stable,

    [Parameter(Mandatory = $false)]
    [switch]$beta,

    [Parameter(Mandatory = $false)]
    [switch]$security,

    [Parameter(Mandatory = $false)]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [int]$BuildNumber,

    [Parameter(Mandatory = $false)]
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

# Read and parse current version from pubspec.yaml
$pubspecText = Get-Content -LiteralPath $pubspecPath -Raw
$versionMatch = [regex]::Match($pubspecText, '(?m)^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$')
if (-not $versionMatch.Success) {
    throw "Could not parse current version from pubspec.yaml."
}

$currentMajor = [int]$versionMatch.Groups[1].Value
$currentMinor = [int]$versionMatch.Groups[2].Value
$currentPatch = [int]$versionMatch.Groups[3].Value
$currentBuild = [int]$versionMatch.Groups[4].Value

$nextMajor = $currentMajor
$nextMinor = $currentMinor
$nextPatch = $currentPatch
$releaseTypeLabel = "Custom"

if ($stable) {
    $nextMajor = $currentMajor + 1
    $nextMinor = 0
    $nextPatch = 0
    $releaseTypeLabel = "Stable Feature Release"
} elseif ($security) {
    $nextMinor = $currentMinor + 1
    $nextPatch = 0
    $releaseTypeLabel = "Security & Quality Release"
} elseif ($beta) {
    $nextPatch = $currentPatch + 1
    $releaseTypeLabel = "Beta Build"
} else {
    if (-not $Version) {
        throw "Please specify the release type parameter (-stable, -beta, -security) or pass -Version explicitly."
    }
}

if (-not $Version) {
    $Version = "$nextMajor.$nextMinor.$nextPatch"
}

if (-not $BuildNumber) {
    $BuildNumber = $currentBuild + 1
}

# 1. Update version across core config files
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
    $text = [regex]::Replace($text, "const appVersion = '[^']+';", "const appVersion = '$Version';")
    $text = [regex]::Replace($text, "const appBuildNumber = '[^']+';", "const appBuildNumber = '$BuildNumber';")
    $text = [regex]::Replace($text, "const appBuildDate = '[^']+';", "const appBuildDate = '$BuildDate';")
    $text
}

# 2. Automate F-Droid / Fastlane Changelog creation
$fastlaneDir = Join-Path $repoRoot "fastlane/metadata/android/en-US/changelogs"
if (-not (Test-Path -LiteralPath $fastlaneDir)) {
    New-Item -ItemType Directory -Path $fastlaneDir -Force | Out-Null
}
$fastlaneFile = Join-Path $fastlaneDir "$BuildNumber.txt"
if (-not (Test-Path -LiteralPath $fastlaneFile)) {
    $fastlaneContent = "Placeholder: Write F-Droid changelog for version $Version (build $BuildNumber) here."
    Set-Content -LiteralPath $fastlaneFile -Value $fastlaneContent -NoNewline
    Write-Host "Created F-Droid changelog template: $fastlaneFile"
}

# 3. Automate GitHub Release notes template creation with optional Security Update prefix
$releaseNotesDir = Join-Path $repoRoot "releases/v$Version"
if (-not (Test-Path -LiteralPath $releaseNotesDir)) {
    New-Item -ItemType Directory -Path $releaseNotesDir -Force | Out-Null
}
$releaseNotesFile = Join-Path $releaseNotesDir "RELEASE_NOTES.md"
if (-not (Test-Path -LiteralPath $releaseNotesFile)) {
    $prefix = ""
    if ($security) {
        $prefix = "## 🛡️ Security Update`r`n`r`n"
    }
    $releaseNotesContent = "${prefix}## Notekar v$Version`r`n`r`nSigned release - built automatically from the branch.`r`n`r`n### Security and Integrity`r`nNoteKar binaries undergo automated compilation and scanning.`r`n- **VirusTotal Report**: https://www.virustotal.com/gui/file/placeholder`r`n"
    Set-Content -LiteralPath $releaseNotesFile -Value $releaseNotesContent -NoNewline
    Write-Host "Created GitHub Release notes template: $releaseNotesFile"
}

# 4. Automate In-App Changelog section injection inside changelog_dialog.dart
$changelogPath = Join-Path $repoRoot "lib/dialogs/changelog_dialog.dart"
if (Test-Path -LiteralPath $changelogPath) {
    $changelogText = Get-Content -LiteralPath $changelogPath -Raw
    $changelogText = $changelogText -replace "`r`n", "`n"
    $versionSearch = "version: '$Version'"
    if ($changelogText -match [regex]::Escape($versionSearch)) {
        Write-Host "Changelog entry for version $Version already exists in changelog_dialog.dart"
    } else {
        $formattedDate = (Get-Date).ToString("MMMM dd, yyyy")
        $newReleaseEntry = "  static const releases = [`n    (`n      version: '$Version',`n      date: '$formattedDate',`n      highlights: [`n        'Placeholder Highlight: Add your main highlights here.',`n      ],`n      items: [`n        'Added: Placeholder changelog items here.',`n      ],`n    ),"
        $changelogText = $changelogText.Replace("  static const releases = [", $newReleaseEntry)
        Set-Content -LiteralPath $changelogPath -Value $changelogText -NoNewline
        Write-Host "Injected new empty in-app changelog section for v$Version inside changelog_dialog.dart"
    }
}

Write-Host ''
Write-Host "Version metadata is ready ($releaseTypeLabel):"
Write-Host "  Version:    $Version"
Write-Host "  Build:      $BuildNumber"
Write-Host "  Build date: $BuildDate"
