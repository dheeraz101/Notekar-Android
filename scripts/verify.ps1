$ErrorActionPreference = 'Stop'

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🚀 Running NoteKar Local CI Verification Suite..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Code Formatting
Write-Host "`n💅 (1/3) Checking code formatting..." -ForegroundColor Yellow
dart format --output=none --set-exit-if-changed lib/ test/
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Formatting check failed! Run 'dart format lib/ test/' to fix." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Code formatting is clean." -ForegroundColor Green

# 2. Static Analysis
Write-Host "`n🔍 (2/3) Running static analysis (flutter analyze --fatal-infos --fatal-warnings)..." -ForegroundColor Yellow
flutter analyze --fatal-infos --fatal-warnings
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Static analysis failed! Please fix analyzer warnings/errors." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Static analysis passed with 0 issues." -ForegroundColor Green

# 3. Test Suite
Write-Host "`n🧪 (3/3) Running test suite (flutter test)..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Automated tests failed! Please resolve failing tests before pushing." -ForegroundColor Red
    exit 1
}
Write-Host "✅ All tests passed successfully!" -ForegroundColor Green

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "🎉 ALL CHECKS PASSED: Ready for Git Push!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
