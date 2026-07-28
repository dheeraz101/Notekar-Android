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

function Update-TextFile
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Update
    )

    $text = Get-Content -LiteralPath $Path -Raw
    $updated = & $Update $text

    if ($updated -eq $text)
    {
        Write-Host "No changes needed: $Path"
        return
    }

    Set-Content -LiteralPath $Path -Value $updated -NoNewline
    Write-Host "Updated: $Path"
}

$pubspecPath = Join-Path $repoRoot 'pubspec.yaml'
$localPropertiesPath = Join-Path $repoRoot 'android/local.properties'
$appUtilsPath = Join-Path $repoRoot 'lib/utils/app_utils.dart'

if (-not (Test-Path -LiteralPath $pubspecPath))
{
    throw "pubspec.yaml was not found at $pubspecPath"
}
if (-not (Test-Path -LiteralPath $localPropertiesPath))
{
    throw "android/local.properties was not found at $localPropertiesPath"
}
if (-not (Test-Path -LiteralPath $appUtilsPath))
{
    throw "lib/utils/app_utils.dart was not found at $appUtilsPath"
}

# Read and parse current version from pubspec.yaml
$pubspecText = Get-Content -LiteralPath $pubspecPath -Raw
$versionMatch = [regex]::Match($pubspecText, '(?m)^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$')
if (-not $versionMatch.Success)
{
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

if ($stable)
{
    $nextMajor = $currentMajor + 1
    $nextMinor = 0
    $nextPatch = 0
    $releaseTypeLabel = "Stable Feature Release"
}
elseif ($security)
{
    $nextMinor = $currentMinor + 1
    $nextPatch = 0
    $releaseTypeLabel = "Security & Quality Release"
}
elseif ($beta)
{
    $nextPatch = $currentPatch + 1
    $releaseTypeLabel = "Beta Build"
}
else
{
    if (-not $Version)
    {
        throw "Please specify the release type parameter (-stable, -beta, -security) or pass -Version explicitly."
    }
}

if (-not $Version)
{
    $Version = "$nextMajor.$nextMinor.$nextPatch"
}

if (-not $BuildNumber)
{
    $BuildNumber = $currentBuild + 1
}

# Parse and clean git log since last version commit to auto-populate user-facing changelogs
$cleanCommits = @()
$features = @()
$improvements = @()
$fixes = @()

try
{
    $startCommit = ""

    # Try finding the last version commit in git history (matching message starting with 'v' and a digit)
    $lastVerCommit = (git log --grep="^v[0-9]" -n 1 --format="%H") 2> $null
    if ($lastVerCommit)
    {
        # If HEAD is already the version commit, skip it to find the previous one
        $headHash = (git rev-parse HEAD) 2> $null
        if ($lastVerCommit -eq $headHash)
        {
            $lastVerCommit = (git log --grep="^v[0-9]" --skip=1 -n 1 --format="%H") 2> $null
        }
    }

    # Fallback to the last git tag if no version commit found
    if (-not $lastVerCommit)
    {
        $lastTag = (git describe --tags --abbrev=0) 2> $null
        if ($lastTag)
        {
            $startCommit = $lastTag
        }
    }
    else
    {
        $startCommit = $lastVerCommit
    }

    if ($startCommit)
    {
        $commitsList = (git log "$startCommit..HEAD" --oneline) 2> $null
    }
    else
    {
        $commitsList = (git log -n 10 --oneline) 2> $null
    }

    if ($commitsList)
    {
        foreach ($line in $commitsList)
        {
            # Strip hash prefix
            $msg = $line -replace '^[0-9a-f]+\s+', ''

            # Strip trailing leaked shell parameters (e.g. -m flags)
            $msg = $msg -replace '\s*"\s*-m\s*.*$', ''
            $msg = $msg -replace '\s*-\s*m\s*.*$', ''
            $msg = $msg.Trim()

            if ( [string]::IsNullOrWhiteSpace($msg))
            {
                continue
            }

            # Identify category based on prefix
            $category = "improvement"
            if ($msg -match '^(feat)(?:\([^)]+\))?:\s*')
            {
                $category = "feature"
            }
            elseif ($msg -match '^(fix|bug)(?:\([^)]+\))?:\s*')
            {
                $category = "fix"
            }
            elseif ($msg -match '^(chore|test|ci|build|docs)(?:\([^)]+\))?:\s*')
            {
                # Skip internal developer commits to keep user-facing release notes clean
                continue
            }

            # Strip conventional commit prefixes like feat:, feat(scope):, style:, refactor:, etc.
            $cleanMsg = $msg -replace '^(feat|fix|style|refactor|perf|docs|chore|test|ci|build)(?:\([^)]+\))?:\s*', ''
            if ($cleanMsg.Length -gt 0)
            {
                $cleanMsg = $cleanMsg.Substring(0, 1).ToUpper() + $cleanMsg.Substring(1)
            }

            # Add to categories (avoid duplicates)
            if ($category -eq "feature")
            {
                if ($features -notcontains $cleanMsg)
                {
                    $features += $cleanMsg
                }
            }
            elseif ($category -eq "fix")
            {
                if ($fixes -notcontains $cleanMsg)
                {
                    $fixes += $cleanMsg
                }
            }
            else
            {
                if ($improvements -notcontains $cleanMsg)
                {
                    $improvements += $cleanMsg
                }
            }

            # Build a list of all clean commits for items list
            if ($cleanCommits -notcontains $cleanMsg)
            {
                $cleanCommits += $cleanMsg
            }
        }
    }
}
catch
{
    # Fallback if git fails
}

# Fallbacks if list is empty
if ($cleanCommits.Count -eq 0)
{
    $fallbackMsg = "Quality improvements and stability enhancements."
    $cleanCommits = @($fallbackMsg)
    $improvements = @($fallbackMsg)
}

# Construct formatted markdown for CHANGELOG.md and RELEASE_NOTES.md
$mdSections = @()
if ($features.Count -gt 0)
{
    $mdSections += "### What's New"
    foreach ($f in $features)
    {
        $mdSections += "- $f"
    }
}
if ($improvements.Count -gt 0)
{
    if ($mdSections.Count -gt 0)
    {
        $mdSections += ""
    }
    $mdSections += "### Improvements"
    foreach ($imp in $improvements)
    {
        $mdSections += "- $imp"
    }
}
if ($fixes.Count -gt 0)
{
    if ($mdSections.Count -gt 0)
    {
        $mdSections += ""
    }
    $mdSections += "### Bug Fixes"
    foreach ($fx in $fixes)
    {
        $mdSections += "- $fx"
    }
}
$gitCommits = $mdSections -join "`r`n"

# Construct formatted list for F-Droid / Fastlane (needs to be extremely concise and bulleted, no markdown headers)
$fastlaneBullets = @()
foreach ($f in $features)
{
    $fastlaneBullets += "- New: $f"
}
foreach ($imp in $improvements)
{
    $fastlaneBullets += "- $imp"
}
foreach ($fx in $fixes)
{
    $fastlaneBullets += "- Fix: $fx"
}
$fastlaneCommits = $fastlaneBullets -join "`r`n"

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
if (-not (Test-Path -LiteralPath $fastlaneDir))
{
    New-Item -ItemType Directory -Path $fastlaneDir -Force | Out-Null
}
$fastlaneFile = Join-Path $fastlaneDir "$BuildNumber.txt"
$fastlaneContent = "Update to $Version (build $BuildNumber):`r`n$fastlaneCommits"
Set-Content -LiteralPath $fastlaneFile -Value $fastlaneContent -NoNewline
Write-Host "Created/Updated F-Droid changelog: $fastlaneFile"

# 3. Automate GitHub Release notes template creation with optional Security Update prefix
$releaseNotesDir = Join-Path $repoRoot "releases/v$Version"
if (-not (Test-Path -LiteralPath $releaseNotesDir))
{
    New-Item -ItemType Directory -Path $releaseNotesDir -Force | Out-Null
}
$releaseNotesFile = Join-Path $releaseNotesDir "RELEASE_NOTES.md"
$prefix = ""
if ($security)
{
    $prefix = "## 🛡️ Security Update`r`n`r`n"
}
$releaseNotesContent = "${prefix}## Notekar v$Version`r`n`r`nSigned release - built automatically from the branch.`r`n`r`n$gitCommits`r`n`r`n### Security and Integrity`r`nNoteKar binaries undergo automated compilation and scanning.`r`n- **VirusTotal Report**: https://www.virustotal.com/gui/file/placeholder`r`n"
Set-Content -LiteralPath $releaseNotesFile -Value $releaseNotesContent -NoNewline
Write-Host "Created/Updated GitHub Release notes template: $releaseNotesFile"

# 4. Automate In-App Changelog section injection inside changelog_dialog.dart
$changelogPath = Join-Path $repoRoot "lib/dialogs/changelog_dialog.dart"
if (Test-Path -LiteralPath $changelogPath)
{
    $changelogText = Get-Content -LiteralPath $changelogPath -Raw
    $changelogText = $changelogText -replace "`r`n", "`n"

    $formattedDate = (Get-Date).ToString("MMMM dd, yyyy")

    # Highlights: use features list
    $hlList = @()
    if ($security)
    {
        $hlList += "Security and stability improvements."
    }
    foreach ($f in $features)
    {
        $hlList += $f
    }
    if ($hlList.Count -eq 0)
    {
        if ($beta)
        {
            $hlList += "Beta testing and feedback build."
        }
        elseif ($stable)
        {
            $hlList += "Stable feature updates and enhancements."
        }
        else
        {
            $hlList += "Quality improvements and stability updates."
        }
    }

    $jsHighlights = ($hlList | ForEach-Object { "        '$_'," }) -join "`n"
    $jsItems = ($cleanCommits | ForEach-Object { "        '$_'," }) -join "`n"

    $newReleaseEntry = "  static const releases = [`n    (`n      version: '$Version',`n      date: '$formattedDate',`n      highlights: [`n$jsHighlights`n      ],`n      items: [`n$jsItems`n      ],`n    ),"

    $entryPattern = "(?s)\(\s*version:\s*'$Version',.*?\),\s*"
    if ($changelogText -match $entryPattern)
    {
        $changelogText = $changelogText -replace $entryPattern, ""
    }
    $changelogText = $changelogText.Replace("  static const releases = [", $newReleaseEntry)
    Set-Content -LiteralPath $changelogPath -Value $changelogText -NoNewline
    Write-Host "Injected/Updated in-app changelog section for v$Version inside changelog_dialog.dart"
}

# 5. Automate CHANGELOG.md updates
$changelogMdPath = Join-Path $repoRoot "CHANGELOG.md"
if (Test-Path -LiteralPath $changelogMdPath)
{
    $changelogMdText = Get-Content -LiteralPath $changelogMdPath -Raw

    $tagSuffix = ""
    if ($beta)
    {
        $tagSuffix = " [BR]"
    }
    elseif ($security)
    {
        $tagSuffix = " [SR]"
    }
    elseif ($stable)
    {
        $tagSuffix = " [SB]"
    }

    $newChangelogEntry = "## [$Version] - $BuildDate (versionCode $BuildNumber)$tagSuffix`r`n`r`n$gitCommits`r`n`r`n"

    $changelogMdPattern = "(?s)## \[$Version\].*?(?=## \[|\Z)"
    if ($changelogMdText -match "## \[$Version\]")
    {
        $changelogMdText = $changelogMdText -replace $changelogMdPattern, $newChangelogEntry
        Write-Host "Updated CHANGELOG.md entry for version $Version"
    }
    else
    {
        $firstHeaderIndex = $changelogMdText.IndexOf("## [")
        if ($firstHeaderIndex -ge 0)
        {
            $changelogMdText = $changelogMdText.Insert($firstHeaderIndex, $newChangelogEntry)
            Write-Host "Injected new changelog section for v$Version inside CHANGELOG.md"
        }
    }
    Set-Content -LiteralPath $changelogMdPath -Value $changelogMdText -NoNewline
}

# 6. Automate README.md badge updates
$readmePath = Join-Path $repoRoot "README.md"
if (Test-Path -LiteralPath $readmePath)
{
    Update-TextFile -Path $readmePath -Update {
        param($text)
        [regex]::Replace($text, 'https://img\.shields\.io/badge/version-\d+\.\d+\.\d+-blue', "https://img.shields.io/badge/version-$Version-blue")
    }
}

Write-Host ''
Write-Host "Version metadata is ready ($releaseTypeLabel):"
Write-Host "  Version:    $Version"
Write-Host "  Build:      $BuildNumber"
Write-Host "  Build date: $BuildDate"
