param(
    [Parameter(Mandatory = $false)]
    [string]$Tag = 'screen',

    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory,

    [Parameter(Mandatory = $false)]
    [switch]$Report
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repoRoot '.artifacts/visual_qa'
}

if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

# 1. Detect connected devices via ADB
$adbDevices = adb devices | Select-String -Pattern "device$" | ForEach-Object { ($_ -split "\t")[0] }

if (-not $adbDevices -or $adbDevices.Count -eq 0) {
    Write-Host "⚠️ No running Android device or emulator found via ADB." -ForegroundColor Yellow
    Write-Host "👉 Start an emulator first using: emulator -avd Pixel_10a" -ForegroundColor Cyan
    Write-Host "   Or launch via Android CLI: android emulator start Pixel_10a" -ForegroundColor Cyan
    exit 1
}

$targetDevice = $adbDevices[0]
Write-Host "📱 Target device: $targetDevice" -ForegroundColor Cyan

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$filename = "${Tag}_${timestamp}.png"
$targetPath = Join-Path $OutputDirectory $filename

Write-Host "📸 Capturing screenshot via ADB..." -ForegroundColor Yellow
& adb -s $targetDevice exec-out screencap -p > $targetPath

if (-not (Test-Path -LiteralPath $targetPath) -or (Get-Item -LiteralPath $targetPath).Length -eq 0) {
    Write-Host "❌ Failed to capture screenshot." -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item -LiteralPath $targetPath).Length / 1KB
Write-Host "✅ Screenshot captured successfully!" -ForegroundColor Green
Write-Host "  • Saved: $targetPath" -ForegroundColor DarkGray
Write-Host "  • Size:  $([math]::Round($fileSize, 2)) KB" -ForegroundColor DarkGray

# 2. Update Visual QA Report if requested
$reportFile = Join-Path $OutputDirectory 'VISUAL_QA_REPORT.md'
$entry = @"

### Screenshot: $Tag
- **Date**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **Device**: $targetDevice
- **File**: `[$filename]($filename)`
- **Image**:
![$Tag]($filename)

---
"@

Add-Content -LiteralPath $reportFile -Value $entry
Write-Host "📝 Updated Visual QA Report at: $reportFile" -ForegroundColor Green
