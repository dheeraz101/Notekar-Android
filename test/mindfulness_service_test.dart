import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/utils/mindfulness_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MindfulnessService Tests', () {
    test('defaults match specifications', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = MindfulnessService.instance;

      expect(service.isEnabled(prefs), false);
      expect(service.getIntervalMins(prefs), 60);
      expect(service.isSoundEnabled(prefs), true);
      expect(service.getCustomMessage(prefs), '');
      expect(service.getStartTime(prefs), const TimeOfDay(hour: 9, minute: 0));
      expect(service.getEndTime(prefs), const TimeOfDay(hour: 22, minute: 0));
    });

    test('active hours calculation works within daytime window', () {
      final service = MindfulnessService.instance;
      const start = TimeOfDay(hour: 9, minute: 0);
      const end = TimeOfDay(hour: 22, minute: 0);

      expect(
        service.isWithinActiveHours(
          const TimeOfDay(hour: 14, minute: 30),
          start,
          end,
        ),
        true,
      );
      expect(
        service.isWithinActiveHours(
          const TimeOfDay(hour: 9, minute: 0),
          start,
          end,
        ),
        true,
      );
      expect(
        service.isWithinActiveHours(
          const TimeOfDay(hour: 22, minute: 0),
          start,
          end,
        ),
        true,
      );
      expect(
        service.isWithinActiveHours(
          const TimeOfDay(hour: 6, minute: 0),
          start,
          end,
        ),
        false,
      );
      expect(
        service.isWithinActiveHours(
          const TimeOfDay(hour: 23, minute: 15),
          start,
          end,
        ),
        false,
      );
    });

    test('active hours calculation works across midnight window', () {
      final service = MindfulnessService.instance;
      const start = TimeOfDay(hour: 21, minute: 0);
      const end = TimeOfDay(hour: 5, minute: 0);

      expect(
        service.isWithinActiveHours(
          const TimeOfDay(hour: 23, minute: 30),
          start,
          end,
        ),
        true,
      );
      expect(
        service.isWithinActiveHours(
          const TimeOfDay(hour: 2, minute: 0),
          start,
          end,
        ),
        true,
      );
      expect(
        service.isWithinActiveHours(
          const TimeOfDay(hour: 12, minute: 0),
          start,
          end,
        ),
        false,
      );
    });
  });
}
