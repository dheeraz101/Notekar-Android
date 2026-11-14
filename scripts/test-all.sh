#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-all}"

echo "=================================================="
echo "🧪 NoteKar Automated Test Gauntlet Runner (POSIX)"
echo "=================================================="

run_suite() {
  local name="$1"
  shift
  echo ""
  echo "▶ Running $name..."
  for file in "$@"; do
    echo "  • $file"
  done
  flutter test "$@"
  echo "✅ $name passed successfully."
}

SMOKE_TESTS=(
  "test/accent_palette_test.dart"
  "test/widget_test.dart"
  "test/haptics_single_burst_test.dart"
  "test/clock_format_test.dart"
)

HIG_TESTS=(
  "test/apple_hig_bitchord_precision_components_test.dart"
  "test/apple_hig_experience_test.dart"
  "test/targeted_apple_hig_test.dart"
)

SECURITY_TESTS=(
  "test/vault_encryption_service_test.dart"
  "test/backup_import_test.dart"
  "test/notekar_data_safety_permissions_content_rating_test.dart"
)

TIMELINE_TESTS=(
  "test/life_ledger_timeline_test.dart"
  "test/phase3_timeline_physics_and_audio_ballistics_test.dart"
  "test/gap_prefill_and_rest_test.dart"
)

case "$MODE" in
  --smoke)
    run_suite "Smoke Suite" "${SMOKE_TESTS[@]}"
    ;;
  --hig)
    run_suite "Apple HIG Suite" "${HIG_TESTS[@]}"
    ;;
  --security)
    run_suite "Security & Vault Suite" "${SECURITY_TESTS[@]}"
    ;;
  --timeline)
    run_suite "Timeline & Ledger Suite" "${TIMELINE_TESTS[@]}"
    ;;
  all|*)
    echo "▶ Running full test suite..."
    flutter test
    echo "✅ Complete test suite passed!"
    ;;
esac

echo ""
echo "=================================================="
echo "🎉 TEST SUITE EXECUTION COMPLETED"
echo "=================================================="
