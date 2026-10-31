import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/add_edit_habit_sheet.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/checkpoint_service.dart';
import 'package:notekar/widgets/checkpoints_quick_bar.dart';
import 'package:notekar/widgets/timeline_voice_player_pill.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CheckpointService.instance.init();
    await CheckpointService.instance.resetToDefaults();
  });

  group('CheckpointService Custom Habit Management', () {
    test('defaultPresetIds are defined and protect core presets', () {
      expect(CheckpointService.defaultPresetIds.contains('wake_up'), isTrue);
      expect(CheckpointService.defaultPresetIds.contains('bath'), isTrue);
      expect(CheckpointService.defaultPresetIds.contains('bedtime'), isTrue);
      expect(
        CheckpointService.defaultPresetIds.contains('custom_habit'),
        isFalse,
      );
    });

    test('addPreset persists new habit and can be retrieved', () async {
      const newHabit = CheckpointPreset(
        id: 'custom_hydration',
        label: 'Drink 2L Water',
        emoji: '💧',
        category: 'Health',
        targetMinuteOfDay: 600, // 10:00 AM
      );

      await CheckpointService.instance.addPreset(newHabit);
      final presets = CheckpointService.instance.presets;

      expect(presets.any((pr) => pr.id == 'custom_hydration'), isTrue);
      final found = presets.firstWhere((pr) => pr.id == 'custom_hydration');
      expect(found.label, 'Drink 2L Water');
      expect(found.emoji, '💧');
      expect(found.category, 'Health');
      expect(found.targetMinuteOfDay, 600);
    });

    test('deletePreset removes habit properly', () async {
      const newHabit = CheckpointPreset(
        id: 'custom_reading',
        label: 'Reading 30m',
        emoji: '📖',
        category: 'Mind',
      );

      await CheckpointService.instance.addPreset(newHabit);
      expect(
        CheckpointService.instance.presets.any(
          (pr) => pr.id == 'custom_reading',
        ),
        isTrue,
      );

      await CheckpointService.instance.deletePreset('custom_reading');
      expect(
        CheckpointService.instance.presets.any(
          (pr) => pr.id == 'custom_reading',
        ),
        isFalse,
      );
    });
  });

  group('NotePreviewItem & NotePreviewSheet Media Symmetry', () {
    test('NotePreviewItem stores imagePath and voice recording details', () {
      const item = NotePreviewItem(
        note: 'I CAN AND I WILL 🔥\nTalk to yourself it really works !',
        title: 'Moment Note',
        category: 'Mind',
        dateStr: '28/10/2026',
        imagePath: '/storage/emulated/0/DCIM/photo.jpg',
        voicePath: '/storage/emulated/0/Music/voice.m4a',
        voiceDurationMs: 17000,
        voicePaths: ['/storage/emulated/0/Music/voice.m4a'],
      );

      expect(item.note, contains('I CAN AND I WILL'));
      expect(item.imagePath, '/storage/emulated/0/DCIM/photo.jpg');
      expect(item.voicePath, '/storage/emulated/0/Music/voice.m4a');
      expect(item.voiceDurationMs, 17000);
      expect(item.voicePaths?.length, 1);
    });

    testWidgets(
      'NotePreviewSheet renders text and navigates between items with media',
      (tester) async {
        final items = [
          const NotePreviewItem(
            note: 'Morning note without media',
            title: 'Moment Note',
            category: 'Routine',
          ),
          const NotePreviewItem(
            note: 'I CAN AND I WILL 🔥\nTalk to yourself it really works !',
            title: 'Moment Note',
            category: 'Mind',
            dateStr: '28/10/2026',
            voicePath: '/dummy/voice.m4a',
            voiceDurationMs: 17000,
            voicePaths: ['/dummy/voice.m4a'],
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotePreviewSheet(
                p: p,
                note: items[0].note,
                title: items[0].title,
                category: items[0].category,
                items: items,
                initialIndex: 0,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(
          find.textContaining('Morning note without media'),
          findsOneWidget,
        );
        expect(find.text('1 of 2'), findsOneWidget);

        // Tap next '>'
        await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
        await tester.pumpAndSettle();

        expect(find.textContaining('I CAN AND I WILL'), findsOneWidget);
        expect(find.text('2 of 2'), findsOneWidget);
      },
    );

    testWidgets(
      'NotePreviewSheet renders pure voice memo with no text without empty placeholder box',
      (tester) async {
        final pureVoiceItem = NotePreviewItem(
          note: '',
          title: 'Voice Memo',
          dateStr: '28/10/2026',
          voicePath: 'test_voice.m4a',
          voiceDurationMs: 17000,
          voicePaths: const ['test_voice.m4a'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotePreviewSheet(
                p: p,
                note: pureVoiceItem.note,
                title: pureVoiceItem.title,
                dateStr: pureVoiceItem.dateStr,
                voicePath: pureVoiceItem.voicePath,
                voiceDurationMs: pureVoiceItem.voiceDurationMs,
                voicePaths: pureVoiceItem.voicePaths,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Empty placeholder 'No text in note.' must NOT be displayed
        expect(find.text('No text in note.'), findsNothing);

        // Voice Player Pill and Header badges must be displayed
        expect(find.byType(TimelineVoicePlayerPill), findsOneWidget);
        expect(find.text('Voice Memo'), findsWidgets);
        expect(find.text('28/10/2026'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.calendar), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.mic_fill), findsOneWidget);
      },
    );

    test(
      'TimelineSessionItem aggregates voice recordings and notes from both IN and OUT moments',
      () {
        final inMom = Moment(
          id: 101,
          timestamp: 1730100000000,
          type: 'in',
          date: '28/10/2026',
          note: 'Workout started',
        );
        final outMom = Moment(
          id: 102,
          timestamp: 1730103600000,
          type: 'out',
          date: '28/10/2026',
          note: 'Finished 5k run',
          voicePath: '/storage/voice_out.m4a',
          voiceDurationMs: 17000,
        );

        final session = TimelineSessionItem(inMoment: inMom, outMoment: outMom);

        expect(session.note, contains('Workout started'));
        expect(session.note, contains('Finished 5k run'));
        expect(session.voicePaths, contains('/storage/voice_out.m4a'));
        expect(session.voiceDurationMs, equals(17000));
      },
    );
  });

  group('CheckpointsQuickBar & AddEditHabitSheet Widget Tests', () {
    testWidgets('CheckpointsQuickBar displays + Add Habit chip', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckpointsQuickBar(
              p: p,
              moments: const <Moment>[],
              onLogCheckpoint: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and Add Habit chip
      expect(find.textContaining('Habits'), findsOneWidget);
      expect(find.text('Add Habit'), findsOneWidget);
    });

    testWidgets(
      'AddEditHabitSheet renders title input, emoji options, and save button',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AddEditHabitSheet(p: p)),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('New Habit Checkpoint'), findsOneWidget);
        expect(find.text('Habit Icon'), findsOneWidget);
        expect(find.text('Habit Name'), findsOneWidget);
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Target Time'), findsOneWidget);
        expect(find.text('Create Habit'), findsOneWidget);

        // Enter title
        await tester.enterText(find.byType(TextField).first, 'Meditate 15m');
        await tester.pumpAndSettle();

        expect(find.text('Meditate 15m'), findsOneWidget);
      },
    );
  });
}
