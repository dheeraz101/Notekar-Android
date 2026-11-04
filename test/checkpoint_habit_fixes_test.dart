import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/add_edit_habit_sheet.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/checkpoint_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/checkpoints_quick_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark', accentName: 'blue');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CheckpointService.instance.init();
    await CheckpointService.instance.resetToDefaults();
  });

  group('AppleHigActionSheet & AppleHigActionItem Tests', () {
    testWidgets(
      'pops with item.value without double-popping or closing screen',
      (tester) async {
        String? returnedAction;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      final res = await AppleHigActionSheet.show<String>(
                        context,
                        p: p,
                        title: 'Habit Actions',
                        actions: [
                          AppleHigActionItem<String>(
                            title: 'Log Checkpoint',
                            icon: CupertinoIcons.checkmark_circle,
                            value: 'log',
                          ),
                          AppleHigActionItem<String>(
                            title: 'Edit Habit',
                            icon: CupertinoIcons.pencil,
                            value: 'edit',
                          ),
                          AppleHigActionItem<String>(
                            title: 'Delete Habit',
                            isDestructive: true,
                            icon: CupertinoIcons.trash,
                            value: 'delete',
                          ),
                        ],
                      );
                      returnedAction = res;
                    },
                    child: const Text('Open Action Sheet'),
                  );
                },
              ),
            ),
          ),
        );

        // Tap button to open action sheet
        await tester.tap(find.text('Open Action Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Habit Actions'), findsOneWidget);
        expect(find.text('Edit Habit'), findsOneWidget);

        // Tap "Edit Habit"
        await tester.tap(find.text('Edit Habit'));
        await tester.pumpAndSettle();

        // Verify returned value is 'edit'
        expect(returnedAction, 'edit');
        // Verify parent screen was NOT popped (ElevatedButton is still present)
        expect(find.text('Open Action Sheet'), findsOneWidget);
      },
    );

    testWidgets('executes onTap callback when provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await AppleHigActionSheet.show<void>(
                      context,
                      p: p,
                      title: 'Note Actions',
                      actions: [
                        AppleHigActionItem(
                          title: 'Custom Action',
                          icon: Icons.star,
                          onTap: () {
                            tapped = true;
                          },
                        ),
                      ],
                    );
                  },
                  child: const Text('Open Note Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Note Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Custom Action'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('CheckpointService Deletion & Listenable Tests', () {
    test('allows deleting default presets and custom presets', () async {
      final initialCount = CheckpointService.instance.presets.length;
      expect(initialCount, greaterThan(0));

      // Delete a default preset (e.g. 'wake_up')
      await CheckpointService.instance.deletePreset('wake_up');
      expect(
        CheckpointService.instance.presets.any((pr) => pr.id == 'wake_up'),
        isFalse,
      );
      expect(
        CheckpointService.instance.presets.length,
        equals(initialCount - 1),
      );

      // Add a custom preset
      const custom = CheckpointPreset(
        id: 'custom_meditate',
        label: 'Meditation',
        emoji: '🧘',
        category: 'Mind',
      );
      await CheckpointService.instance.addPreset(custom);
      expect(
        CheckpointService.instance.presets.any(
          (pr) => pr.id == 'custom_meditate',
        ),
        isTrue,
      );

      // Delete the custom preset
      await CheckpointService.instance.deletePreset('custom_meditate');
      expect(
        CheckpointService.instance.presets.any(
          (pr) => pr.id == 'custom_meditate',
        ),
        isFalse,
      );

      // Reset to defaults
      await CheckpointService.instance.resetToDefaults();
      expect(
        CheckpointService.instance.presets.any((pr) => pr.id == 'wake_up'),
        isTrue,
      );
      expect(CheckpointService.instance.presets.length, equals(initialCount));
    });

    test('notifies listeners when presets change', () async {
      int notifications = 0;
      void listener() => notifications++;

      CheckpointService.instance.addListener(listener);

      await CheckpointService.instance.deletePreset('bath');
      expect(notifications, 1);

      await CheckpointService.instance.resetToDefaults();
      expect(notifications, 2);

      CheckpointService.instance.removeListener(listener);
    });
  });

  group('CategoryService renameCategory Tests', () {
    test(
      'renames category and updates cache, checkpoints, and moments',
      () async {
        final catService = CategoryService.instance;

        // Add a custom category
        await catService.addCategory('Study', color: const Color(0xFF007AFF));
        final allCats = await catService.getCategories();
        expect(allCats.contains('Study'), isTrue);

        // Add checkpoint with this category
        const preset = CheckpointPreset(
          id: 'custom_reading',
          label: 'Reading',
          emoji: '📖',
          category: 'Study',
        );
        await CheckpointService.instance.addPreset(preset);

        // Add moment with this category
        final moment = Moment(
          id: 99991,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(DateTime.now()),
          note: 'Studying algorithms',
          category: 'Study',
        );
        await MomentRepository.instance.saveMoment(moment);

        // Perform category rename: Study -> Research
        final success = await catService.renameCategory('Study', 'Research');
        expect(success, isTrue);

        // Verify category list updated
        final updatedCats = await catService.getCategories();
        expect(updatedCats.contains('Study'), isFalse);
        expect(updatedCats.contains('Research'), isTrue);

        // Verify checkpoint preset category cascaded
        final updatedPreset = CheckpointService.instance.presets.firstWhere(
          (pr) => pr.id == 'custom_reading',
        );
        expect(updatedPreset.category, 'Research');

        // Verify moment category cascaded
        final updatedMoment = MomentRepository.instance
            .getAllMoments()
            .firstWhere((m) => m.id == 99991);
        expect(updatedMoment.category, 'Research');
      },
    );
  });

  group('CheckpointsQuickBar & Habit Interaction Tests', () {
    testWidgets(
      'renders habits and exposes Delete Habit on long press for all habits',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckpointsQuickBar(
                p: p,
                moments: const [],
                onLogCheckpoint: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify habit chips exist (e.g. 'Waking Up')
        expect(find.text('Waking Up'), findsOneWidget);

        // Long press on 'Waking Up'
        await tester.longPress(find.text('Waking Up'));
        await tester.pumpAndSettle();

        // Action sheet should appear with Log, Edit, and Delete options
        expect(find.text('Log Checkpoint'), findsOneWidget);
        expect(find.text('Edit Habit'), findsOneWidget);
        expect(find.text('Delete Habit'), findsOneWidget);
      },
    );
  });

  group('AddEditHabitSheet Widget Tests', () {
    testWidgets('renders within Material bounds and loads categories', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AddEditHabitSheet.show(context, p: p);
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

      // Verify sheet title
      expect(find.text('New Habit Checkpoint'), findsOneWidget);
      expect(find.text('Habit Icon'), findsOneWidget);
      expect(find.text('Habit Name'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('New Category'), findsOneWidget);
      expect(find.text('Create Habit'), findsOneWidget);
    });

    testWidgets(
      'editing existing habit and deleting via confirmation sheet works',
      (tester) async {
        const targetPreset = CheckpointPreset(
          id: 'habit_to_delete',
          label: 'Habit To Delete',
          emoji: '🗑️',
          category: 'Routine',
        );
        await CheckpointService.instance.addPreset(targetPreset);

        bool? sheetResult;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      sheetResult = await AddEditHabitSheet.show(
                        context,
                        p: p,
                        preset: targetPreset,
                      );
                    },
                    child: const Text('Edit Habit'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Edit Habit'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Habit'), findsWidgets);
        expect(find.byIcon(CupertinoIcons.trash), findsOneWidget);

        // Tap trash button to trigger confirmation
        await tester.tap(find.byIcon(CupertinoIcons.trash));
        await tester.pumpAndSettle();

        expect(find.text('Delete Habit Checkpoint'), findsOneWidget);

        // Tap confirm "Delete Habit"
        await tester.tap(find.text('Delete Habit').last);
        await tester.pumpAndSettle();

        // Verify sheet closed with true
        expect(sheetResult, isTrue);

        // Verify preset is deleted from CheckpointService
        expect(
          CheckpointService.instance.presets.any(
            (pr) => pr.id == 'habit_to_delete',
          ),
          isFalse,
        );
      },
    );

    testWidgets('editing existing habit updates name and saves', (
      tester,
    ) async {
      const initialPreset = CheckpointPreset(
        id: 'habit_to_rename',
        label: 'Old Routine',
        emoji: '💧',
        category: 'Health',
      );
      await CheckpointService.instance.addPreset(initialPreset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AddEditHabitSheet.show(
                      context,
                      p: p,
                      preset: initialPreset,
                    );
                  },
                  child: const Text('Edit Habit'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Edit Habit'));
      await tester.pumpAndSettle();

      // Change habit name (habit name field is the second TextField; first is emoji)
      final nameField = find.byType(TextField).at(1);
      await tester.enterText(nameField, 'Hydration Champion');
      await tester.pumpAndSettle();

      // Tap "Save Changes"
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Verify saved in CheckpointService
      final updated = CheckpointService.instance.presets.firstWhere(
        (pr) => pr.id == 'habit_to_rename',
      );
      expect(updated.label, 'Hydration Champion');
    });
  });
}
