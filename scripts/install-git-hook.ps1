$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$gitHooksDir = Join-Path $repoRoot '.git/hooks'

if (-not (Test-Path -LiteralPath $gitHooksDir)) {
    Write-Error "Git repository was not found. Make sure this repository is initialized with git (under .git)."
}

$preCommitFile = Join-Path $gitHooksDir 'pre-commit'
$prePushFile = Join-Path $gitHooksDir 'pre-push'

# 1. Pre-commit hook: Auto-formats and checks static analysis quickly on every commit
$preCommitContent = @'
#!/bin/sh
echo "🔍 Running Git Pre-Commit Hook checks..."

# Auto-format files on commit
echo "💅 Formatting code with dart format..."
dart format lib/ test/
RESULT_FORMAT=$?
if [ $RESULT_FORMAT -ne 0 ]; then
  echo "❌ [PRE-COMMIT ERROR] Code formatting failed."
  exit 1
fi

# Re-stage formatted files
git add -u

# Run flutter analyze to prevent committing broken files
echo "🔍 Running static analysis with flutter analyze..."
flutter analyze
RESULT_ANALYZE=$?
if [ $RESULT_ANALYZE -ne 0 ]; then
  echo "❌ [PRE-COMMIT ERROR] Static analysis check failed! Please fix issues before committing."
  exit 1
fi

echo "✅ [PRE-COMMIT PASSED] All pre-commit checks passed successfully."
exit 0
'@

# 2. Pre-push hook: Full CI parity check before git push
$prePushContent = @'
#!/bin/sh
echo "🛡️  [PRE-PUSH HOOK] Running CI verification checks before push..."

# 1. Format check
echo "💅 (1/3) Checking code formatting..."
dart format --output=none --set-exit-if-changed lib/ test/
RESULT_FORMAT=$?
if [ $RESULT_FORMAT -ne 0 ]; then
  echo ""
  echo "❌ [PRE-PUSH ERROR] Unformatted Dart code detected."
  echo "👉 Fix: Run 'dart format lib/ test/' and commit the changes before pushing."
  exit 1
fi

# 2. Static analysis
echo "🔍 (2/3) Running static analysis (flutter analyze --fatal-infos --fatal-warnings)..."
flutter analyze --fatal-infos --fatal-warnings
RESULT_ANALYZE=$?
if [ $RESULT_ANALYZE -ne 0 ]; then
  echo ""
  echo "❌ [PRE-PUSH ERROR] Static analysis check failed! Please fix issues before pushing."
  exit 1
fi

# 3. Test suite
echo "🧪 (3/3) Running complete automated test suite (flutter test)..."
flutter test
RESULT_TEST=$?
if [ $RESULT_TEST -ne 0 ]; then
  echo ""
  echo "❌ [PRE-PUSH ERROR] Test suite failed! One or more tests did not pass."
  echo "👉 Fix: Ensure all tests pass locally before pushing to remote."
  exit 1
fi

echo "✅ [PRE-PUSH PASSED] All checks (Format, Static Analysis, Unit & Widget Tests) passed! Proceeding with push."
exit 0
'@

Set-Content -LiteralPath $preCommitFile -Value $preCommitContent -NoNewline
Set-Content -LiteralPath $prePushFile -Value $prePushContent -NoNewline

Write-Host "✅ Git hooks installed successfully!" -ForegroundColor Green
Write-Host "  • Pre-Commit: $preCommitFile (Auto-format + static analysis)"
Write-Host "  • Pre-Push:   $prePushFile (Format check + fatal static analysis + full test suite)"
Write-Host "Git push is now guarded: no push will succeed if tests or linter fail."
