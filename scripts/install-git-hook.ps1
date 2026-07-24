$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$gitHooksDir = Join-Path $repoRoot '.git/hooks'

if (-not (Test-Path -LiteralPath $gitHooksDir)) {
    Write-Error "Git repository was not found. Make sure this repository is initialized with git (under .git)."
}

$preCommitFile = Join-Path $gitHooksDir 'pre-commit'

$hookContent = @'
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

# Run flutter analyze to prevent pushing broken files
echo "🔍 Running static analysis with flutter analyze..."
flutter analyze
RESULT_ANALYZE=$?
if [ $RESULT_ANALYZE -ne 0 ]; then
  echo "❌ [PRE-COMMIT ERROR] Static analysis check failed! Please fix issues before committing."
  exit 1
fi

echo "✅ [PRE-COMMIT PASSED] All checks passed successfully."
exit 0
'@

Set-Content -LiteralPath $preCommitFile -Value $hookContent -NoNewline
Write-Host "✅ Git pre-commit hook installed successfully at: $preCommitFile"
Write-Host "It will now automatically verify 'flutter analyze' before any git commit."
