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

# Run flutter analyze to prevent pushing broken files
flutter analyze
RESULT=$?
if [ $RESULT -ne 0 ]; then
  echo "❌ [PRE-COMMIT ERROR] Static analysis check failed! Please fix issues before committing."
  exit 1
fi

echo "✅ [PRE-COMMIT PASSED] All checks passed successfully."
exit 0
'@

Set-Content -LiteralPath $preCommitFile -Value $hookContent -NoNewline
Write-Host "✅ Git pre-commit hook installed successfully at: $preCommitFile"
Write-Host "It will now automatically verify 'flutter analyze' before any git commit."
