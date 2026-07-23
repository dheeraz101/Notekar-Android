param(
    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 2100000000)]
    [int]$BuildNumber,

    [Parameter(Mandatory = $false)]
    [switch]$SkipClean,

    [Parameter(Mandatory = $false)]
    [switch]$NoTreeShake
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

function Read-PubspecVersion {
    $pubspecPath = Join-Path $repoRoot 'pubspec.yaml'
    $pubspecText = Get-Content -LiteralPath $pubspecPath -Raw
    $match = [regex]::Match($pubspecText, '(?m)^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$')

    if (-not $match.Success) {
        throw 'Could not read version from pubspec.yaml. Expected a line like: version: 4.0.4+13'
    }

    [pscustomobject]@{
        Version = $match.Groups[1].Value
        BuildNumber = [int]$match.Groups[2].Value
    }
}

function Find-Flutter {
    $localPropertiesPath = Join-Path $repoRoot 'android/local.properties'
    if (Test-Path -LiteralPath $localPropertiesPath) {
        $flutterSdkLine = Get-Content -LiteralPath $localPropertiesPath |
            Where-Object { $_ -match '^flutter\.sdk=' } |
            Select-Object -First 1

        if ($flutterSdkLine) {
            $flutterSdk = ($flutterSdkLine -replace '^flutter\.sdk=', '').Trim()
            $flutterSdk = $flutterSdk -replace '\\\\', '\'
            $flutterBat = Join-Path $flutterSdk 'bin/flutter.bat'
            if (Test-Path -LiteralPath $flutterBat) {
                return $flutterBat
            }
        }
    }

    return 'flutter'
}

function Require-ReleaseSigning {
    $keyPropertiesPath = Join-Path $repoRoot 'android/key.properties'
    if (-not (Test-Path -LiteralPath $keyPropertiesPath)) {
        throw 'android/key.properties is missing. Add release signing properties before building signed release APKs.'
    }

    $properties = @{}
    Get-Content -LiteralPath $keyPropertiesPath | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.*?)\s*$') {
            $properties[$matches[1].Trim()] = $matches[2].Trim()
        }
    }

    foreach ($key in @('storeFile', 'storePassword', 'keyAlias', 'keyPassword')) {
        if (-not $properties.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($properties[$key])) {
            throw "android/key.properties is missing '$key'."
        }
    }

    $storeFile = $properties['storeFile']
    if (-not [System.IO.Path]::IsPathRooted($storeFile)) {
        $storeFile = Join-Path (Join-Path $repoRoot 'android') $storeFile
    }

    if (-not (Test-Path -LiteralPath $storeFile)) {
        throw "Release keystore was not found: $storeFile"
    }
}

function Copy-Apk {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Expected APK was not created: $Source"
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Host "Copied: $Destination"
}

function Write-HashFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ApkPaths,

        [Parameter(Mandatory = $true)]
        [string[]]$HashFilePaths
    )

    $hashLines = foreach ($apkPath in ($ApkPaths | Sort-Object)) {
        $hash = (Get-FileHash -LiteralPath $apkPath -Algorithm SHA256).Hash.ToLowerInvariant()
        "$hash  $(Split-Path -Leaf $apkPath)"
    }

    foreach ($hashFilePath in $HashFilePaths) {
        $hashText = ($hashLines -join [Environment]::NewLine) + [Environment]::NewLine
        Set-Content -LiteralPath $hashFilePath -Value $hashText -NoNewline
        Write-Host "Wrote: $hashFilePath"
    }

    $hashLines
}

function Write-VersionManifest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Version,

        [Parameter(Mandatory = $true)]
        [int]$BuildNumber,

        [Parameter(Mandatory = $true)]
        [string[]]$ApkPaths
    )

    $apkEntries = foreach ($apkPath in ($ApkPaths | Sort-Object)) {
        [pscustomobject]@{
            file = Split-Path -Leaf $apkPath
            sha256 = (Get-FileHash -LiteralPath $apkPath -Algorithm SHA256).Hash.ToLowerInvariant()
            bytes = (Get-Item -LiteralPath $apkPath).Length
        }
    }

    $manifest = [pscustomobject]@{
        version = $Version
        buildNumber = $BuildNumber
        generatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
        apks = $apkEntries
    }

    $manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $Path
    Write-Host "Wrote: $Path"
}

function Write-GitHubRelease {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Version,

        [Parameter(Mandatory = $true)]
        [string[]]$HashLines
    )

    $fence = '```'
    # Use ### Assets to match our Premium release notes style
    $downloads = @(
        "- Universal: ``notekar-$Version-universal.apk``"
        "- ARM64: ``notekar-$Version-arm64-v8a.apk``"
        "- ARMv7: ``notekar-$Version-armeabi-v7a.apk``"
        "- x86_64: ``notekar-$Version-x86_64.apk``"
    ) -join [Environment]::NewLine

    $shaBlock = $HashLines -join [Environment]::NewLine

    $assetsSection = @"
### Assets

$downloads
"@

    $shaSection = @"
### SHA256

${fence}text
$shaBlock
$fence
"@

    if (Test-Path -LiteralPath $Path) {
        $releaseText = Get-Content -LiteralPath $Path -Raw

        # Try to replace ### Assets or ## Downloads
        if ($releaseText -match '(?ms)^### Assets\s+') {
            $releaseText = [regex]::Replace($releaseText, '(?ms)^### Assets\s+.*?(?=^### |^## |\z)', $assetsSection.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine)
        } elseif ($releaseText -match '(?ms)^## Downloads\s+') {
            $releaseText = [regex]::Replace($releaseText, '(?ms)^## Downloads\s+.*?(?=^## |^### |\z)', "## Assets" + [Environment]::NewLine + [Environment]::NewLine + $downloads.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine)
        } else {
            $releaseText = $releaseText.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $assetsSection.TrimEnd() + [Environment]::NewLine
        }

        # Try to replace ### SHA256 or ## SHA256
        if ($releaseText -match '(?ms)^### SHA256\s+') {
            $releaseText = [regex]::Replace($releaseText, '(?ms)^### SHA256\s+.*?(?=^### |^## |\z)', $shaSection.TrimEnd() + [Environment]::NewLine)
        } elseif ($releaseText -match '(?ms)^## SHA256\s+') {
            $releaseText = [regex]::Replace($releaseText, '(?ms)^## SHA256\s+.*?(?=^## |^### |\z)', $shaSection.TrimEnd() + [Environment]::NewLine)
        } else {
            $releaseText = $releaseText.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $shaSection.TrimEnd() + [Environment]::NewLine
        }
    } else {
        $releaseText = @"
# NoteKar $Version

$($assetsSection.TrimEnd())

$($shaSection.TrimEnd())
"@
    }

    Set-Content -LiteralPath $Path -Value ($releaseText.TrimEnd() + [Environment]::NewLine) -NoNewline
    Write-Host "Updated Release Note: $Path"
}

$pubspecVersion = Read-PubspecVersion
if (-not $Version) {
    $Version = $pubspecVersion.Version
}

if (-not $BuildNumber) {
    $BuildNumber = $pubspecVersion.BuildNumber
}

# Pre-flight Release Checks
try {
    $gitStatus = (git status --porcelain) 2>$null
    if ($gitStatus) {
        Write-Warning "You have uncommitted changes in your git workspace. It is highly recommended to commit all changes before generating release builds."
    }
} catch {}

$flutter = Find-Flutter

Write-Host "🔍 Running pre-flight static analysis..."
& $flutter analyze
if ($LASTEXITCODE -ne 0) {
    throw "Static analysis failed. Please fix code quality issues before building release APKs."
}
Write-Host "✅ Static analysis passed."

Require-ReleaseSigning

$releaseDir = Join-Path $repoRoot "releases/v$Version"
$versionsDir = Join-Path $repoRoot "versions/v$Version"
$apkOutputDir = Join-Path $repoRoot 'build/app/outputs/flutter-apk'

New-Item -ItemType Directory -Force -Path $releaseDir, $versionsDir | Out-Null

if (-not $SkipClean) {
    & $flutter clean
}

$extraFlags = @()
if ($NoTreeShake) {
    $extraFlags += '--no-tree-shake-icons'
}

& $flutter pub get
& $flutter build apk --release --build-name $Version --build-number $BuildNumber @extraFlags
& $flutter build apk --release --split-per-abi --build-name $Version --build-number $BuildNumber @extraFlags

$apkMap = @(
    @{ Source = 'app-arm64-v8a-release.apk'; Destination = "notekar-$Version-arm64-v8a.apk" }
    @{ Source = 'app-armeabi-v7a-release.apk'; Destination = "notekar-$Version-armeabi-v7a.apk" }
    @{ Source = 'app-release.apk'; Destination = "notekar-$Version-universal.apk" }
    @{ Source = 'app-x86_64-release.apk'; Destination = "notekar-$Version-x86_64.apk" }
)

$releaseApks = foreach ($apk in $apkMap) {
    $source = Join-Path $apkOutputDir $apk.Source
    $destination = Join-Path $releaseDir $apk.Destination
    Copy-Apk -Source $source -Destination $destination
    $destination
}

$hashLines = Write-HashFiles -ApkPaths $releaseApks -HashFilePaths @(
    (Join-Path $releaseDir 'sha256.txt'),
    (Join-Path $versionsDir 'sha256.txt'),
    (Join-Path $repoRoot 'sha256.txt')
)

Write-VersionManifest -Path (Join-Path $versionsDir 'version.json') -Version $Version -BuildNumber $BuildNumber -ApkPaths $releaseApks
Write-GitHubRelease -Path (Join-Path $releaseDir 'GITHUB_RELEASE.md') -Version $Version -HashLines $hashLines

Write-Host ''
Write-Host "Release APKs are ready:"
Write-Host "  $releaseDir"
Write-Host "Version metadata is ready:"
Write-Host "  $versionsDir"
