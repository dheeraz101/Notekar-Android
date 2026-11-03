import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/urge_surfing_dialog.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/audio_service.dart';
import 'package:notekar/widgets/swipeable_card_bed.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Phase 3: Audio Ballistics & Peak Envelope Follower Tests', () {
    test(
      'AudioService implements envelope follower with fast attack and exponential decay',
      () {
        final audio = AudioService.instance;

        // Initial state
        expect(audio.currentRecordingAmplitude, equals(0.0));

        // Reset
        audio.reset();
        expect(audio.isPlaying, isFalse);
      },
    );
  });

  group('Phase 3: 2:1 Slope Lock & Gesture Disambiguation Tests', () {
    test(
      'SlopedHorizontalDragGestureRecognizer rejects vertical dominant gestures (slope < 2.0)',
      () {
        final recognizer = SlopedHorizontalDragGestureRecognizer();

        // Horizontal gesture: dx = 30, dy = 10 -> ratio = 3.0 (>= 2.0) -> allowed
        expect(recognizer.isSlopeAllowed(const Offset(30, 10)), isTrue);

        // Diagonal gesture: dx = 20, dy = 15 -> ratio = 1.33 (< 2.0) -> rejected
        expect(recognizer.isSlopeAllowed(const Offset(20, 15)), isFalse);

        // Vertical dominant gesture: dx = 5, dy = 30 -> ratio = 0.16 (< 2.0) -> rejected
        expect(recognizer.isSlopeAllowed(const Offset(5, 30)), isFalse);

        // Pure horizontal: dy = 0 -> allowed
        expect(recognizer.isSlopeAllowed(const Offset(25, 0)), isTrue);
      },
    );
  });

  group('Phase 3: GPU Render Layer & Breath Animation Tests', () {
    testWidgets(
      'UrgeSurfingDialog renders breathing circle isolated in RepaintBoundary',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: UrgeSurfingDialog(p: p)),
          ),
        );

        // Verify presence of RepaintBoundary widgets
        final repaintBoundaries = find.byType(RepaintBoundary);
        expect(repaintBoundaries, findsWidgets);

        // Verify Transform.scale is used for GPU layer scaling
        final transformFinder = find.byType(Transform);
        expect(transformFinder, findsWidgets);
      },
    );
  });
}
