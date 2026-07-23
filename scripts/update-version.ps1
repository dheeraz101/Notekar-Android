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
} else {
    Write-Host "F-Droid changelog file for build $BuildNumber already exists."
}

# 3. Automate GitHub Release notes template creation
$releaseNotesDir = Join-Path $repoRoot "releases/v$Version"
if (-not (Test-Path -LiteralPath $releaseNotesDir)) {
    New-Item -ItemType Directory -Path $releaseNotesDir -Force | Out-Null
}
$releaseNotesFile = Join-Path $releaseNotesDir "RELEASE_NOTES.md"
if (-not (Test-Path -LiteralPath $releaseNotesFile)) {
    $releaseNotesContent = "## Notekar v$Version`r`n`r`nSigned release - built automatically from the branch.`r`n`r`n### Security and Integrity`r`nNoteKar binaries undergo automated compilation and scanning.`r`n- **VirusTotal Report**: https://www.virustotal.com/gui/file/placeholder`r`n"
    Set-Content -LiteralPath $releaseNotesFile -Value $releaseNotesContent -NoNewline
    Write-Host "Created GitHub Release notes template: $releaseNotesFile"
} else {
    Write-Host "GitHub Release notes file for v$Version already exists."
}

# 4. Automate In-App Changelog section injection inside changelog_dialog.dart
$changelogPath = Join-Path $repoRoot "lib/dialogs/changelog_dialog.dart"
if (Test-Path -LiteralPath $changelogPath) {
    $changelogText = Get-Content -LiteralPath $changelogPath -Raw
    # Normalize line endings in file for consistent matching
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
Write-Host "Version metadata is ready:"
Write-Host "  Version:    $Version"
Write-Host "  Build:      $BuildNumber"
Write-Host "  Build date: $BuildDate"
