param(
    [Parameter(Mandatory = $false)]
    [switch]$Smoke,

    [Parameter(Mandatory = $false)]
    [switch]$HigOnly,

    [Parameter(Mandatory = $false)]
    [switch]$TimelineOnly,

    [Parameter(Mandatory = $false)]
    [switch]$SecurityOnly
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🧪 NoteKar Automated Test Gauntlet Runner" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

function Run-TestSuite {
    param(
        [string]$Name,
        [string[]]$Paths
    )

    Write-Host "`n▶ Running $Name..." -ForegroundColor Yellow
    foreach ($path in $Paths) {
        Write-Host "  • $path" -ForegroundColor DarkGray
    }

    $args = @('test') + $Paths
    & flutter $args
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ $Name failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ $Name passed successfully." -ForegroundColor Green
}

# 1. Smoke Tests Tier
$smokeTests = @(
    'test/accent_palette_test.dart',
    'test/widget_test.dart',
    'test/haptics_single_burst_test.dart',
    'test/clock_format_test.dart'
)

# 2. Apple HIG Components Tier
$higTests = @(
    'test/apple_hig_bitchord_precision_components_test.dart',
    'test/apple_hig_experience_test.dart',
    'test/settings_navigation_and_custom_switch_test.dart',
    'test/search_bars_centering_test.dart',
    'test/targeted_apple_hig_test.dart'
)

# 3. Timeline & Session Lifecycle Tier
$timelineTests = @(
    'test/life_ledger_timeline_test.dart',
    'test/dual_soul_session_test.dart',
    'test/gap_prefill_and_rest_test.dart',
    'test/single_numbering_test.dart',
    'test/checkpoint_habit_fixes_test.dart'
)

# 4. Security & Cryptographic Vault Tier
$securityTests = @(
    'test/vault_encryption_service_test.dart',
    'test/migration_compatibility_test.dart',
    'test/backup_import_test.dart',
    'test/notekar_data_safety_permissions_content_rating_test.dart'
)

if ($Smoke) {
    Run-TestSuite -Name "Tier 1: Smoke Tests" -Paths $smokeTests
} elseif ($HigOnly) {
    Run-TestSuite -Name "Tier 2: Apple HIG Component Tests" -Paths $higTests
} elseif ($TimelineOnly) {
    Run-TestSuite -Name "Tier 3: Timeline & Session Lifecycle Tests" -Paths $timelineTests
} elseif ($SecurityOnly) {
    Run-TestSuite -Name "Tier 4: Security & Vault Tests" -Paths $securityTests
} else {
    Write-Host "`n🚀 Executing Complete Full-Suite Test Gauntlet..." -ForegroundColor Cyan
    & flutter test
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n❌ Full test gauntlet failed! Review the failing tests above." -ForegroundColor Red
        exit 1
    }
    Write-Host "`n🎉 ALL TEST SUITES PASSED (100% GREEN)!" -ForegroundColor Green
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "✅ Test Runner Finished with Exit Code 0" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
