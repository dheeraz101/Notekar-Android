import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/checkpoint_session_sheet.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/checkpoint_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/settings_controller.dart';
import 'package:notekar/utils/update_service.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/home_minimal_toolbar_capsule.dart';
import 'package:notekar/widgets/toolbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockHttpOverrides extends HttpOverrides {
  final Map<String, String> responses;
  final int statusCode;

  _MockHttpOverrides({required this.responses, this.statusCode = 200});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(responses: responses, statusCode: statusCode);
  }
}

class _MockHttpClient implements HttpClient {
  final Map<String, String> responses;
  final int statusCode;

  _MockHttpClient({required this.responses, this.statusCode = 200});

  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  bool autoUncompress = true;
  @override
  String? userAgent;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest(
      url: url,
      responses: responses,
      defaultStatus: statusCode,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final Uri url;
  final Map<String, String> responses;
  final int defaultStatus;

  _MockHttpClientRequest({
    required this.url,
    required this.responses,
    required this.defaultStatus,
  });

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    final body = responses[url.toString()];
    if (body != null) {
      return _MockHttpClientResponse(statusCode: 200, body: body);
    }
    return _MockHttpClientResponse(
      statusCode: defaultStatus,
      body: 'Not Found',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  final Map<String, Object> _headers = {};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name.toLowerCase()] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final String body;

  _MockHttpClientResponse({required this.statusCode, required this.body});

  @override
  int get contentLength => utf8.encode(body).length;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(utf8.encode(body)).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lightPalette = paletteFor('light', accentName: 'blue');
  final darkPalette = paletteFor('dark', accentName: 'blue');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CheckpointService.instance.init();
    await CheckpointService.instance.resetToDefaults();
  });

  group('User Feedback Fix 1: Routine / Habits Tag in History', () {
    testWidgets('HistoryDialog displays Routine filter pill in primary row', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryDialog(
              p: darkPalette,
              entries: const [],
              compactRows: false,
              largeText: false,
              minimalMomentOptions: false,
              confirmDelete: false,
              onDelete: (_) async {},
              onRestore: (_) async {},
              onUpdateNote: (_, _) async {},
              onDuration: (_, _) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for Routine pill in primary row
      expect(find.text('Routine'), findsOneWidget);
      expect(find.byIcon(Icons.flag_rounded), findsWidgets);

      // Tap Routine pill
      await tester.tap(find.text('Routine'));
      await tester.pumpAndSettle();

      // Empty state for Routine checkpoints should be visible
      expect(find.text('No Checkpoints'), findsOneWidget);
    });

    test(
      'buildTimelineDataInIsolate accurately filters checkpoints when filter == checkpoints',
      () {
        final now = DateTime.now();
        final todayStr = dateKey(now);

        final momentSingleCheckpoint = Moment(
          id: 101,
          timestamp: now
              .subtract(const Duration(minutes: 10))
              .millisecondsSinceEpoch,
          date: dateKey(now.subtract(const Duration(minutes: 10))),
          type: 'single',
          tags: ['checkpoint:hydration'],
          note: 'Drank water',
        );

        final momentSingleRegular = Moment(
          id: 102,
          timestamp: now
              .subtract(const Duration(minutes: 20))
              .millisecondsSinceEpoch,
          date: dateKey(now.subtract(const Duration(minutes: 20))),
          type: 'single',
          tags: ['work'],
          note: 'Regular work note',
        );

        final momentSessionInCheckpoint = Moment(
          id: 103,
          timestamp: now
              .subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          date: dateKey(now.subtract(const Duration(hours: 1))),
          type: 'in',
          tags: ['checkpoint:workout'],
          note: 'Workout started',
        );

        final momentSessionOutCheckpoint = Moment(
          id: 104,
          timestamp: now
              .subtract(const Duration(minutes: 30))
              .millisecondsSinceEpoch,
          date: dateKey(now.subtract(const Duration(minutes: 30))),
          type: 'out',
          tags: ['checkpoint:workout'],
          note: 'Workout finished',
        );

        final momentSessionInRegular = Moment(
          id: 105,
          timestamp: now
              .subtract(const Duration(hours: 3))
              .millisecondsSinceEpoch,
          date: dateKey(now.subtract(const Duration(hours: 3))),
          type: 'in',
          tags: ['study'],
          note: 'Studying',
        );

        final momentSessionOutRegular = Moment(
          id: 106,
          timestamp: now
              .subtract(const Duration(hours: 2))
              .millisecondsSinceEpoch,
          date: dateKey(now.subtract(const Duration(hours: 2))),
          type: 'out',
          tags: ['study'],
          note: 'Study finished',
        );

        final payload = TimelineIsolatePayload(
          entries: [
            momentSingleCheckpoint,
            momentSingleRegular,
            momentSessionInCheckpoint,
            momentSessionOutCheckpoint,
            momentSessionInRegular,
            momentSessionOutRegular,
          ],
          includeGaps: false,
          filter: 'checkpoints',
          today: todayStr,
          weekAgo: now.subtract(const Duration(days: 7)),
        );

        final result = buildTimelineDataInIsolate(payload);

        // Verify sections contain only checkpoint items
        expect(result.sections, isNotEmpty);
        final allItems = result.sections.expand((s) => s.items).toList();

        // Must contain single checkpoint moment (101)
        expect(
          allItems.any((it) => it is TimelineSingleItem && it.moment.id == 101),
          isTrue,
        );

        // Must NOT contain single regular moment (102)
        expect(
          allItems.any((it) => it is TimelineSingleItem && it.moment.id == 102),
          isFalse,
        );

        // Must contain session checkpoint moments (103/104)
        expect(
          allItems.any(
            (it) => it is TimelineSessionItem && it.inMoment.id == 103,
          ),
          isTrue,
        );

        // Must NOT contain regular session moments (105/106)
        expect(
          allItems.any(
            (it) => it is TimelineSessionItem && it.inMoment.id == 105,
          ),
          isFalse,
        );
      },
    );
  });

  group('User Feedback Fix 2: In-app Update Fallback Checksum Verification', () {
    const channel = MethodChannel('notekar/files');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            if (call.method == 'getFileSha256') {
              return 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'verifyApkHash falls back to version.json when sha256.txt fails',
      () async {
        final service = UpdateService();
        final info = AppUpdateInfo(
          version: '7.5.12',
          tagName: 'v7.5.12',
          body: 'Test update body',
          isSecurity: false,
          isImportant: false,
          type: 'Release',
        );

        final fakeVersionJson = jsonEncode({
          'apks': [
            {
              'file': 'notekar-7.5.12-arm64-v8a.apk',
              'sha256':
                  'E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855',
            },
          ],
        });

        final mockOverrides = _MockHttpOverrides(
          responses: {
            'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/refs/tags/v7.5.12/build/app/outputs/flutter-apk/version.json':
                fakeVersionJson,
          },
          statusCode: 404,
        );

        await HttpOverrides.runWithHttpOverrides(() async {
          final isVerified = await service.verifyApkHash(
            info,
            '/storage/emulated/0/Download/notekar-7.5.12-arm64-v8a.apk',
          );
          expect(isVerified, isTrue);
        }, mockOverrides);
      },
    );

    test(
      'verifyApkHash returns false if checksum does not match in version.json',
      () async {
        final service = UpdateService();
        final info = AppUpdateInfo(
          version: '7.5.12',
          tagName: 'v7.5.12',
          body: 'Test update body',
          isSecurity: false,
          isImportant: false,
          type: 'Release',
        );

        final fakeVersionJson = jsonEncode({
          'apks': [
            {
              'file': 'notekar-7.5.12-arm64-v8a.apk',
              'sha256': '0000000000000000000000000000000000000000',
            },
          ],
        });

        final mockOverrides = _MockHttpOverrides(
          responses: {
            'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/refs/tags/v7.5.12/build/app/outputs/flutter-apk/version.json':
                fakeVersionJson,
          },
          statusCode: 404,
        );

        await HttpOverrides.runWithHttpOverrides(() async {
          final isVerified = await service.verifyApkHash(
            info,
            '/storage/emulated/0/Download/notekar-7.5.12-arm64-v8a.apk',
          );
          expect(isVerified, isFalse);
        }, mockOverrides);
      },
    );
  });

  group(
    'User Feedback Fix 3: Theme and Accent Dual-Key Persistence Across Updates',
    () {
      test(
        'SettingsController loads legacy m-theme and m-accent-color fallback',
        () async {
          SharedPreferences.setMockInitialValues({
            'm-theme': 'amoled',
            'm-accent-color': 'emerald',
          });

          final prefs = await SharedPreferences.getInstance();
          final controller = SettingsController(prefs);

          expect(controller.theme, 'amoled');
          expect(controller.accentColor, 'emerald');
        },
      );

      test(
        'SettingsController dual-writes theme and accent_color keys',
        () async {
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final controller = SettingsController(prefs);

          await controller.setTheme('amoled');
          await controller.setAccentColor('sunset');

          expect(prefs.getString('theme'), 'amoled');
          expect(prefs.getString('m-theme'), 'amoled');
          expect(prefs.getString('accent_color'), 'sunset');
          expect(prefs.getString('m-accent-color'), 'sunset');
        },
      );
    },
  );

  group('User Feedback Fix 4: Light Mode Contrast & System UI Tokens', () {
    testWidgets('Toolbar in light mode has high-contrast border and opacity', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: Toolbar(
              p: lightPalette,
              mode: 'single',
              onMode: () {},
              onHistory: () {},
              onSettings: () {},
              showLabels: true,
              largeControls: false,
              showBackgroundPill: true,
              animateIcons: false,
              showHistoryText: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoratedBoxes = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      expect(decoratedBoxes, isNotEmpty);

      // Find the main toolbar capsule DecoratedBox with borderRadius 999
      final navPill = decoratedBoxes.firstWhere(
        (d) =>
            d.decoration is BoxDecoration &&
            (d.decoration as BoxDecoration).borderRadius ==
                BorderRadius.circular(999),
      );
      final dec = navPill.decoration as BoxDecoration;
      expect(dec.border, isNotNull);
      final border = dec.border as Border;
      expect(border.top.width, 0.8);
      // Border color has RGB #D1D1D6 (209, 209, 214) with alpha > 0.5
      expect(border.top.color.r > 0.8, isTrue);
      expect(border.top.color.g > 0.8, isTrue);
      expect(border.top.color.b > 0.8, isTrue);
    });

    testWidgets(
      'HomeMinimalToolbarCapsule in light mode uses high-contrast border and dark icons',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: HomeMinimalToolbarCapsule(
                  palette: lightPalette,
                  mode: 'single',
                  enableTranslucency: true,
                  onToggleMode: () {},
                  onOpenHistory: () {},
                  onOpenSettings: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify capsule container has #D1D1D6 border
        final containers = tester.widgetList<Container>(find.byType(Container));
        final decorated = containers.where(
          (c) => c.decoration is BoxDecoration,
        );
        final hasBorder = decorated.any((c) {
          final border = (c.decoration as BoxDecoration).border;
          if (border is Border &&
              border.top.color.value ==
                  const Color(0xFFD1D1D6).withValues(alpha: 0.85).value) {
            return true;
          }
          return false;
        });
        expect(hasBorder, isTrue);
      },
    );

    testWidgets(
      'showIosPillToast in light mode renders dark text and border, avoiding white on white',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showIosPillToast(
                        context: context,
                        p: lightPalette,
                        message: 'Habit Logged',
                        icon: Icons.check_circle_rounded,
                      );
                    },
                    child: const Text('Show Toast'),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Toast'));
        await tester.pump(); // Trigger overlay entry insertion
        await tester.pump(
          const Duration(milliseconds: 100),
        ); // Halfway into animation

        final titleText = tester.widget<Text>(find.text('Habit Logged'));
        // Light mode text color must be dark graphite Color(0xFF1C1C1E)
        expect(titleText.style?.color, const Color(0xFF1C1C1E));
      },
    );
  });

  group('User Feedback Fix 5: Natural Forward-Time Duration Scheduling', () {
    testWidgets(
      'Increasing duration advances the end time forward instead of decreasing start time',
      (tester) async {
        DateTime? loggedStart;
        DateTime? loggedEnd;

        const preset = CheckpointPreset(
          id: 'reading',
          label: 'Reading',
          emoji: '📚',
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
                        p: darkPalette,
                        preset: preset,
                        onLogSession:
                            ({required start, required end, note}) async {
                              loggedStart = start;
                              loggedEnd = end;
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

        // Default duration is 30m. Tap '45m' chip.
        final pill45 = find.text('45m');
        expect(pill45, findsOneWidget);
        await tester.ensureVisible(pill45);
        await tester.pumpAndSettle();
        await tester.tap(pill45);
        await tester.pumpAndSettle();

        // Tap Log 2-Way Session
        final logBtn = find.text('Log 2-Way Session');
        await tester.ensureVisible(logBtn);
        await tester.pumpAndSettle();
        await tester.tap(logBtn);
        await tester.pumpAndSettle();

        expect(loggedStart, isNotNull);
        expect(loggedEnd, isNotNull);

        // Difference must be exactly 45 minutes
        final durationDiff = loggedEnd!.difference(loggedStart!);
        expect(durationDiff.inMinutes, 45);

        // Logged start must be prior to or equal to logged end
        expect(loggedEnd!.isAfter(loggedStart!), isTrue);
      },
    );
  });

  group(
    'User Feedback Fix 6: Custom Duration iOS-style CupertinoTimerPicker & + Pill',
    () {
      testWidgets(
        'Plus icon pill exists and opens CupertinoTimerPicker sheet',
        (tester) async {
          const preset = CheckpointPreset(
            id: 'focus',
            label: 'Deep Focus',
            emoji: '🧠',
            category: 'Work',
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
                          p: darkPalette,
                          preset: preset,
                          onLogSession:
                              ({required start, required end, note}) async {},
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

          // Verify + button exists at end of quick duration row
          final plusFinder = find.byIcon(CupertinoIcons.plus);
          expect(plusFinder, findsOneWidget);

          // Scroll to make sure it's visible if necessary and tap
          await tester.ensureVisible(plusFinder);
          await tester.pumpAndSettle();
          await tester.tap(plusFinder);
          await tester.pumpAndSettle();

          // Verify CupertinoTimerPicker modal bottom sheet opened
          expect(find.byType(CupertinoTimerPicker), findsOneWidget);
          expect(find.text('Custom Duration'), findsOneWidget);
          expect(find.text('Done'), findsOneWidget);

          // Tap 'Done' to confirm
          await tester.tap(find.text('Done'));
          await tester.pumpAndSettle();

          // Modal closed
          expect(find.byType(CupertinoTimerPicker), findsNothing);
        },
      );
    },
  );

  group(
    'User Feedback Fix 7: Outlined Apple HIG Button for Single Timestamp Log',
    () {
      testWidgets(
        'Log as single timestamp renders as OutlinedButton.icon and triggers callback',
        (tester) async {
          DateTime? capturedSingleTimestamp;

          const preset = CheckpointPreset(
            id: 'coffee',
            label: 'Espresso',
            emoji: '☕',
            category: 'Routine',
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
                          p: darkPalette,
                          preset: preset,
                          onLogSession:
                              ({required start, required end, note}) async {},
                          onLogSingle: ({required timestamp, note}) async {
                            capturedSingleTimestamp = timestamp;
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

          // Verify prominent button
          expect(find.text('Log as single timestamp'), findsOneWidget);
          expect(
            find.byIcon(Icons.radio_button_checked_rounded),
            findsOneWidget,
          );
          expect(find.byType(OutlinedButton), findsWidgets);

          // Tap Log as single timestamp
          await tester.tap(find.text('Log as single timestamp'));
          await tester.pumpAndSettle();

          expect(capturedSingleTimestamp, isNotNull);
        },
      );
    },
  );

  group('User Feedback Fix 8: 5m and 10m Quick Durations in Habit Popup', () {
    testWidgets('5m and 10m pills are rendered and adjust session duration', (
      tester,
    ) async {
      DateTime? loggedStart;
      DateTime? loggedEnd;

      const preset = CheckpointPreset(
        id: 'breath',
        label: 'Mindful Breathing',
        emoji: '🧘',
        category: 'Health',
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
                      p: darkPalette,
                      preset: preset,
                      onLogSession:
                          ({required start, required end, note}) async {
                            loggedStart = start;
                            loggedEnd = end;
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

      // Check that 5m and 10m chips are present
      expect(find.text('5m'), findsOneWidget);
      expect(find.text('10m'), findsOneWidget);

      // Tap 5m
      await tester.tap(find.text('5m'));
      await tester.pumpAndSettle();

      // Tap Log 2-Way Session
      await tester.tap(find.text('Log 2-Way Session'));
      await tester.pumpAndSettle();

      expect(loggedStart, isNotNull);
      expect(loggedEnd, isNotNull);
      expect(loggedEnd!.difference(loggedStart!).inMinutes, 5);
    });

    testWidgets('10m pill adjusts session duration to 10 minutes', (
      tester,
    ) async {
      DateTime? loggedStart;
      DateTime? loggedEnd;

      const preset = CheckpointPreset(
        id: 'quick_stretch',
        label: 'Quick Stretch',
        emoji: '🤸',
        category: 'Health',
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
                      p: darkPalette,
                      preset: preset,
                      onLogSession:
                          ({required start, required end, note}) async {
                            loggedStart = start;
                            loggedEnd = end;
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

      // Tap 10m
      await tester.tap(find.text('10m'));
      await tester.pumpAndSettle();

      // Tap Log 2-Way Session
      await tester.tap(find.text('Log 2-Way Session'));
      await tester.pumpAndSettle();

      expect(loggedStart, isNotNull);
      expect(loggedEnd, isNotNull);
      expect(loggedEnd!.difference(loggedStart!).inMinutes, 10);
    });

    testWidgets(
      'Tapping End Point with 120m duration opens CupertinoDatePicker safely without assertion error',
      (tester) async {
        const preset = CheckpointPreset(
          id: 'deep_work',
          label: 'Deep Work',
          emoji: '💻',
          category: 'Work',
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
                        p: darkPalette,
                        preset: preset,
                        onLogSession:
                            ({required start, required end, note}) async {},
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

        // Tap 120m pill to set duration to 2 hours in the future
        final pill120 = find.text('2h');
        expect(pill120, findsOneWidget);
        await tester.ensureVisible(pill120);
        await tester.pumpAndSettle();
        await tester.tap(pill120);
        await tester.pumpAndSettle();

        // Tap the End Point tile
        final endPointTile = find.text('END POINT');
        expect(endPointTile, findsOneWidget);
        await tester.tap(endPointTile);
        await tester.pumpAndSettle();

        // CupertinoDatePicker modal sheet must open safely without throwing assertion error
        expect(find.byType(CupertinoDatePicker), findsOneWidget);
        expect(find.text('Select End Point'), findsOneWidget);

        // Tap Done to dismiss
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoDatePicker), findsNothing);
      },
    );

    test(
      'verifyApkHash validates valid APK binary structure when no remote manifest is published',
      () async {
        final service = UpdateService();
        final tempDir = Directory.systemTemp.createTempSync(
          'notekar_test_apk_',
        );
        final apkFile = File('${tempDir.path}/notekar-8.0.0-arm64-v8a.apk');

        // Create dummy file >= 1MB with standard PK ZIP magic header (0x50, 0x4B, 0x03, 0x04)
        final dummyBytes = Uint8List(1024 * 1024 + 16);
        dummyBytes[0] = 0x50;
        dummyBytes[1] = 0x4B;
        dummyBytes[2] = 0x03;
        dummyBytes[3] = 0x04;
        apkFile.writeAsBytesSync(dummyBytes);

        final updateInfo = AppUpdateInfo(
          version: '8.0.0',
          tagName: 'v8.0.0',
          body: 'Release without sha256 manifest',
          isSecurity: false,
          isImportant: true,
          type: 'SB (Stable Build)',
        );

        // Register mock file channel for sha256
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('notekar/files'), (
              call,
            ) async {
              if (call.method == 'getFileSha256') {
                return 'dummyhash12345';
              }
              return null;
            });

        // Run with MockHttpOverrides returning 404 for all network manifests
        await HttpOverrides.runZoned(
          () async {
            final verified = await service.verifyApkHash(
              updateInfo,
              apkFile.path,
            );
            expect(verified, isTrue);
          },
          createHttpClient: (ctx) =>
              _MockHttpClient(responses: {}, statusCode: 404),
        );

        tempDir.deleteSync(recursive: true);
      },
    );
  });
}
