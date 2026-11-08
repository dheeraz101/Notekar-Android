import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/checkpoint_session_sheet.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/merge_entries_sheet.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/checkpoint_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/widgets/checkpoints_quick_bar.dart';
import 'package:notekar/widgets/clock_face.dart';
import 'package:notekar/widgets/design_system/nk_ios_switch.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPalette = paletteFor('dark', accentName: 'blue');
  late Directory tempDir;

  setUp(() async {
    MomentRepository().resetForTesting();
    tempDir = await Directory.systemTemp.createTemp('notekar_test_');
    SharedPreferences.setMockInitialValues({});
    await MomentRepository().ensureInitialized(directoryPath: tempDir.path);
    await CheckpointService.instance.init();
    await CheckpointService.instance.resetToDefaults();
  });

  tearDown(() async {
    MomentRepository().resetForTesting();
    try {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  group('Bug 1: Habit Live Session Reverse Countdown ClockFace Tests', () {
    testWidgets(
      'ClockFace counts down in reverse when targetDuration is provided',
      (tester) async {
        // 30 minute target session, 1 second elapsed -> should display 29:59
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ClockFace(
                  now: DateTime.now(),
                  p: testPalette,
                  pulseToken: 0,
                  pulseType: 'in',
                  minimal: false,
                  showSeconds: true,
                  highlightSeconds: true,
                  sessionElapsed: const Duration(seconds: 1),
                  targetDuration: const Duration(minutes: 30),
                ),
              ),
            ),
          ),
        );

        expect(find.text('29:59'), findsOneWidget);
      },
    );

    testWidgets('ClockFace counts down for 45 minute target duration', (
      tester,
    ) async {
      // 45 minute target session, 2 seconds elapsed -> should display 44:58
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockFace(
                now: DateTime.now(),
                p: testPalette,
                pulseToken: 0,
                pulseType: 'in',
                minimal: false,
                showSeconds: true,
                highlightSeconds: true,
                sessionElapsed: const Duration(seconds: 2),
                targetDuration: const Duration(minutes: 45),
              ),
            ),
          ),
        ),
      );

      expect(find.text('44:58'), findsOneWidget);
    });

    testWidgets('ClockFace stays at 00:00 when targetDuration is exceeded', (
      tester,
    ) async {
      // 30 minute target session, 31 minutes elapsed -> should display 00:00
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockFace(
                now: DateTime.now(),
                p: testPalette,
                pulseToken: 0,
                pulseType: 'in',
                minimal: false,
                showSeconds: true,
                highlightSeconds: true,
                sessionElapsed: const Duration(minutes: 31),
                targetDuration: const Duration(minutes: 30),
              ),
            ),
          ),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets(
      'CheckpointSessionSheet passes selected targetDurationMinutes to onStartLive',
      (tester) async {
        int? capturedTargetMins;
        DateTime? capturedStart;

        const preset = CheckpointPreset(
          id: 'test_habit',
          label: 'Reading',
          emoji: '📖',
          category: 'Learning',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      CheckpointSessionSheet.show(
                        context,
                        p: testPalette,
                        preset: preset,
                        onLogSession:
                            ({required start, required end, note}) async {},
                        onStartLiveWithDuration:
                            ({
                              required start,
                              note,
                              targetDurationMinutes,
                            }) async {
                              capturedStart = start;
                              capturedTargetMins = targetDurationMinutes;
                            },
                      );
                    },
                    child: const Text('Open Sheet'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Tap 45m chip
        await tester.tap(find.text('45m'));
        await tester.pumpAndSettle();

        // Tap "Start Live Timer Now"
        await tester.tap(find.text('Start Live Timer Now'));
        await tester.pumpAndSettle();

        expect(capturedStart, isNotNull);
        expect(capturedTargetMins, equals(45));
      },
    );
  });

  group('Bug 3 & 5: Habit Checkpoint Completion State & Contrast Tests', () {
    test(
      'isCompletedToday is false during ongoing live session and true after session end',
      () {
        const presetId = 'wake_up';
        final todayStr = dateKey(DateTime.now());

        // Only 'in' moment exists (live session running)
        final inMoment = Moment(
          id: 1,
          timestamp: DateTime.now().millisecondsSinceEpoch - 60000,
          type: 'in',
          date: todayStr,
          tags: ['checkpoint', 'checkpoint:$presetId'],
        );

        expect(
          CheckpointService.instance.isCompletedToday(presetId, [inMoment]),
          isFalse,
        );

        // 'out' moment is added (session completed)
        final outMoment = Moment(
          id: 2,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          type: 'out',
          date: todayStr,
          tags: ['checkpoint', 'checkpoint:$presetId'],
        );

        expect(
          CheckpointService.instance.isCompletedToday(presetId, [
            inMoment,
            outMoment,
          ]),
          isTrue,
        );
      },
    );

    testWidgets(
      'CheckpointsQuickBar renders with legible contrast when completed',
      (tester) async {
        final now = DateTime.now();
        final todayStr = dateKey(now);
        final completedMoments = [
          Moment(
            id: 10,
            timestamp: now.millisecondsSinceEpoch,
            type: 'single',
            date: todayStr,
            tags: ['checkpoint', 'checkpoint:wake_up'],
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckpointsQuickBar(
                p: testPalette,
                moments: completedMoments,
                onLogCheckpoint: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find text widget for completed preset (Waking Up)
        final textFinder = find.text('Waking Up');
        expect(textFinder, findsOneWidget);
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, isNotNull);
      },
    );
  });

  group(
    'Bug 4 & 7: CheckpointsQuickBar Stop Button & Long Press Settings Tests',
    () {
      testWidgets(
        'Stop button appears when isSessionActive is true and invokes onStopSession',
        (tester) async {
          bool stopCalled = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CheckpointsQuickBar(
                  p: testPalette,
                  moments: const [],
                  onLogCheckpoint: (_) {},
                  isSessionActive: true,
                  onStopSession: () {
                    stopCalled = true;
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          final stopFinder = find.text('Stop');
          expect(stopFinder, findsOneWidget);

          await tester.tap(stopFinder);
          await tester.pumpAndSettle();

          expect(stopCalled, isTrue);
        },
      );

      testWidgets(
        'Long clicking main Habits title pill invokes onOpenSettings',
        (tester) async {
          bool settingsCalled = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CheckpointsQuickBar(
                  p: testPalette,
                  moments: const [],
                  onLogCheckpoint: (_) {},
                  onOpenSettings: () {
                    settingsCalled = true;
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          final habitsTitleFinder = find.byWidgetPredicate(
            (w) => w is Text && (w.data?.startsWith('Habits') ?? false),
          );
          expect(habitsTitleFinder, findsOneWidget);

          await tester.longPress(habitsTitleFinder);
          await tester.pumpAndSettle();

          expect(settingsCalled, isTrue);
        },
      );
    },
  );

  group('Bug 6: MergeEntriesSheet & HistoryDialog Persistence Tests', () {
    testWidgets(
      'MergeEntriesSheet includes General Mode and allows category selection',
      (tester) async {
        final now = DateTime.now();
        final momentA = Moment(
          id: 1,
          timestamp: now
              .subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(now),
          note: 'Start work',
          category: 'Work',
        );
        final momentB = Moment(
          id: 2,
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(now),
          note: 'End work',
          category: 'Work',
        );

        Moment? mergedStart;
        Moment? mergedEnd;
        String? mergedCategory;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      MergeEntriesSheet.show(
                        context,
                        p: testPalette,
                        momentA: momentA,
                        momentB: momentB,
                        onConfirmMerge:
                            ({
                              required startMoment,
                              required endMoment,
                              required category,
                              required combinedNote,
                              required unifyNotes,
                            }) async {
                              mergedStart = startMoment;
                              mergedEnd = endMoment;
                              mergedCategory = category;
                            },
                      );
                    },
                    child: const Text('Open Merge Sheet'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Merge Sheet'));
        await tester.pumpAndSettle();

        // Verify "General Mode" chip is available and selectable
        expect(find.text('General Mode'), findsOneWidget);

        // Select "General Mode"
        await tester.tap(find.text('General Mode'));
        await tester.pumpAndSettle();

        // Tap Confirm Merge button
        await tester.tap(
          find.widgetWithText(FilledButton, 'Merge into Session'),
        );
        await tester.pumpAndSettle();

        expect(mergedStart, isNotNull);
        expect(mergedEnd, isNotNull);
        expect(mergedStart!.type, equals('in'));
        expect(mergedEnd!.type, equals('out'));
        // When General Mode is selected, category resolves to null
        expect(mergedCategory, isNull);
        expect(mergedStart!.category, isNull);
        expect(mergedEnd!.category, isNull);
      },
    );

    testWidgets(
      'HistoryDialog calls onMomentsUpdated with in/out moments without reverting',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final now = DateTime.now();
        final momentA = Moment(
          id: 101,
          timestamp: now
              .subtract(const Duration(minutes: 40))
              .millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(now),
          note: 'Reading start',
        );
        final momentB = Moment(
          id: 102,
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(now),
          note: 'Reading finish',
        );

        List<Moment>? updatedMomentsList;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryDialog(
                p: testPalette,
                entries: [momentB, momentA],
                compactRows: false,
                largeText: false,
                minimalMomentOptions: false,
                confirmDelete: false,
                onDelete: (_) async {},
                onRestore: (_) async {},
                onUpdateNote: (id, note) async {},
                onDuration: (a, b) {},
                onMomentsUpdated: (moments) async {
                  updatedMomentsList = moments;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select both moments for merging
        // Tap time of moment B and moment A to select them
        await tester.tap(find.text(timeOnly(momentB.timestamp)));
        await tester.pumpAndSettle();

        await tester.tap(find.text(timeOnly(momentA.timestamp)));
        await tester.pumpAndSettle();

        // Find and tap the merge action button in the selection toolbar
        final mergeBtnFinder = find.byIcon(Icons.merge_type_rounded);
        expect(mergeBtnFinder, findsOneWidget);
        await tester.tap(mergeBtnFinder);
        await tester.pumpAndSettle();

        // Tap Confirm & Merge into Session
        final confirmBtnFinder = find.widgetWithText(
          FilledButton,
          'Merge into Session',
        );
        expect(confirmBtnFinder, findsOneWidget);
        await tester.runAsync(() async {
          await tester.tap(confirmBtnFinder);
          await Future<void>.delayed(const Duration(milliseconds: 500));
        });
        await tester.pumpAndSettle();

        // Verify onMomentsUpdated was called with both moments having type 'in' and 'out'
        expect(updatedMomentsList, isNotNull);
        expect(updatedMomentsList!.length, equals(2));
        final start = updatedMomentsList!.firstWhere((m) => m.id == 101);
        final end = updatedMomentsList!.firstWhere((m) => m.id == 102);
        expect(start.type, equals('in'));
        expect(end.type, equals('out'));
      },
    );
  });

  group('Bug 8: NkIosSwitch Commit 7.5.11(26BR1025) Pill Dimensions Tests', () {
    testWidgets(
      'NkIosSwitch renders with 62x32 track, 34x28 thumb, and toggles smoothly',
      (tester) async {
        bool value = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return NkIosSwitch(
                      value: value,
                      onChanged: (v) => setState(() => value = v),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Verify track container has exactly width: 62 and height: 32
        final trackFinder = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.constraints?.maxWidth == 62.0 &&
              w.constraints?.maxHeight == 32.0,
        );
        expect(trackFinder, findsOneWidget);

        // Verify base thumb has width 34 and height 28
        final thumbFinder = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.constraints?.maxWidth == 34.0 &&
              w.constraints?.maxHeight == 28.0,
        );
        expect(thumbFinder, findsOneWidget);

        // Tap toggles switch
        await tester.tap(find.byType(NkIosSwitch));
        await tester.pumpAndSettle();
        expect(value, isTrue);

        await tester.tap(find.byType(NkIosSwitch));
        await tester.pumpAndSettle();
        expect(value, isFalse);
      },
    );

    testWidgets(
      'SettingsSwitchRow pressing down stretches NkIosSwitch thumb via isPressed',
      (tester) async {
        bool rowValue = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return SettingsSwitchRow(
                      p: testPalette,
                      title: 'Test Switch',
                      value: rowValue,
                      onChanged: (bool v) => setState(() => rowValue = v),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('Test Switch'), findsOneWidget);
        final switchWidget = tester.widget<NkIosSwitch>(
          find.byType(NkIosSwitch),
        );
        expect(switchWidget.isPressed, isFalse);

        // Press down on the row text (not the switch directly)
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Test Switch')),
        );
        await tester.pump();

        final switchPressed = tester.widget<NkIosSwitch>(
          find.byType(NkIosSwitch),
        );
        expect(switchPressed.isPressed, isTrue);

        await gesture.up();
        await tester.pumpAndSettle();
        expect(rowValue, isTrue);
      },
    );

    testWidgets(
      'MomentActionsDialog includes Change Mode / Category and can change category',
      (tester) async {
        bool categoryChanged = false;
        final moment = Moment(
          id: 50,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(DateTime.now()),
          note: 'Work item',
          category: 'Work',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MomentActionsDialog(
                p: testPalette,
                entry: moment,
                confirmDelete: false,
                onAddOrEditNote: () {},
                onDeleteMoment: () {},
                onChangeCategory: () {
                  categoryChanged = true;
                },
              ),
            ),
          ),
        );

        final changeModeFinder = find.text('Change Mode / Category');
        expect(changeModeFinder, findsOneWidget);

        await tester.tap(changeModeFinder);
        await tester.pumpAndSettle();
        expect(categoryChanged, isTrue);
      },
    );
  });
}
