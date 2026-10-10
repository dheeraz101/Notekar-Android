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

# Check code formatting
echo "💅 Checking code formatting with dart format..."
dart format --output=none --set-exit-if-changed lib/ test/
RESULT_FORMAT=$?
if [ $RESULT_FORMAT -ne 0 ]; then
  echo "❌ [PRE-COMMIT ERROR] Unformatted code detected."
  echo "👉 Fix: Run 'dart format lib/ test/' and stage the changes before committing."
  exit 1
fi

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
# NoteKar Pre-Push Guard Hook
# Ensures 100% CI parity before any branch is pushed to remote.

echo ""
echo "=========================================================="
echo "🛡️  [PRE-PUSH GUARD] Verifying NoteKar quality gates..."
echo "=========================================================="

# Check if standard input indicates branch deletion
has_input=false
is_delete=false
if [ ! -t 0 ]; then
  while read -r local_ref local_sha remote_ref remote_sha; do
    has_input=true
    if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
      is_delete=true
    else
      is_delete=false
      break
    fi
  done
fi

if [ "$has_input" = true ] && [ "$is_delete" = true ]; then
  echo "ℹ️  Branch deletion detected. Skipping quality checks."
  exit 0
fi

# Step 1: Format check
echo ""
echo "💅 (1/3) Checking code formatting ('dart format --output=none --set-exit-if-changed lib/ test/')..."
dart format --output=none --set-exit-if-changed lib/ test/
FORMAT_EXIT=$?
if [ $FORMAT_EXIT -ne 0 ]; then
  echo ""
  echo "❌ [PRE-PUSH BLOCKED] Unformatted Dart code detected!"
  echo "👉 Fix: Run 'dart format lib/ test/' and commit the changes before pushing."
  echo "=========================================================="
  exit 1
fi
echo "✅ Code formatting is clean."

# Step 2: Static Analysis
echo ""
echo "🔍 (2/3) Running static analysis ('flutter analyze --fatal-infos --fatal-warnings')..."
flutter analyze --fatal-infos --fatal-warnings
ANALYZE_EXIT=$?
if [ $ANALYZE_EXIT -ne 0 ]; then
  echo ""
  echo "❌ [PRE-PUSH BLOCKED] Static analysis failed with fatal warnings or errors!"
  echo "👉 Fix: Resolve all analysis warnings and errors listed above before pushing."
  echo "=========================================================="
  exit 1
fi
echo "✅ Flutter static analysis passed with zero warnings and zero errors."

# Step 3: Test Suite
echo ""
echo "🧪 (3/3) Running complete test suite ('flutter test')..."
flutter test
TEST_EXIT=$?
if [ $TEST_EXIT -ne 0 ]; then
  echo ""
  echo "❌ [PRE-PUSH BLOCKED] Test suite failed! One or more tests did not pass."
  echo "👉 Fix: Resolve all failing tests shown above before pushing."
  echo "=========================================================="
  exit 1
fi
echo "✅ All tests passed successfully."

echo ""
echo "=========================================================="
echo "🎉 [PRE-PUSH PASSED] All quality gates passed! Proceeding with push."
echo "=========================================================="
echo ""
exit 0
'@

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($preCommitFile, ($preCommitContent.Trim() -replace "`r`n", "`n") + "`n", $utf8NoBom)
[System.IO.File]::WriteAllText($prePushFile, ($prePushContent.Trim() -replace "`r`n", "`n") + "`n", $utf8NoBom)

Write-Host "✅ Git hooks installed successfully!" -ForegroundColor Green
Write-Host "  • Pre-Commit: $preCommitFile (Auto-format + static analysis)"
Write-Host "  • Pre-Push:   $prePushFile (Format check + fatal static analysis + full test suite)"
Write-Host "Git push is now guarded: no push will succeed if tests or linter fail."
