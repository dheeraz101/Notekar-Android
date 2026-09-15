import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/utils/app_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotekarHaptics Single Tactile Feedback Tests', () {
    final List<String> hapticCalls = [];

    setUp(() {
      hapticCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall call,
          ) async {
            if (call.method == 'HapticFeedback.vibrate') {
              hapticCalls.add(call.arguments as String? ?? 'default');
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test(
      'NotekarHaptics.save emits single vibration for out moments without delayed secondary burst',
      () async {
        NotekarHaptics.save('standard', 'out');

        expect(hapticCalls.length, 1);
        expect(hapticCalls.first, 'HapticFeedbackType.mediumImpact');

        // Wait 100ms to verify no delayed second vibration fires
        await Future.delayed(const Duration(milliseconds: 100));
        expect(hapticCalls.length, 1);
      },
    );

    test('NotekarHaptics.save emits single vibration for in moments', () async {
      NotekarHaptics.save('standard', 'in');

      expect(hapticCalls.length, 1);
      expect(hapticCalls.first, 'HapticFeedbackType.mediumImpact');

      await Future.delayed(const Duration(milliseconds: 100));
      expect(hapticCalls.length, 1);
    });

    test(
      'NotekarHaptics.successDouble emits single vibration without delayed second burst',
      () async {
        NotekarHaptics.successDouble('standard');

        expect(hapticCalls.length, 1);
        expect(hapticCalls.first, 'HapticFeedbackType.mediumImpact');

        await Future.delayed(const Duration(milliseconds: 100));
        expect(hapticCalls.length, 1);
      },
    );

    test('NotekarHaptics.selection respects off style', () {
      NotekarHaptics.selection('off');
      expect(hapticCalls, isEmpty);
    });
  });
}
