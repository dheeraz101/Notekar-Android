#!/usr/bin/env bash
set -euo pipefail

echo "=================================================="
echo "🚀 Running NoteKar Local CI Verification Suite (POSIX)..."
echo "=================================================="

# 1. Code Formatting
echo ""
echo "💅 (1/3) Checking code formatting..."
dart format --output=none --set-exit-if-changed lib/ test/
echo "✅ Code formatting is clean."

# 2. Static Analysis
echo ""
echo "🔍 (2/3) Running static analysis (flutter analyze --fatal-infos --fatal-warnings)..."
flutter analyze --fatal-infos --fatal-warnings
echo "✅ Static analysis passed with 0 issues."

# 3. Test Suite
echo ""
echo "🧪 (3/3) Running test suite (flutter test)..."
flutter test
echo "✅ All tests passed successfully!"

echo ""
echo "=================================================="
echo "🎉 ALL CHECKS PASSED: Ready for Git Push!"
echo "=================================================="
