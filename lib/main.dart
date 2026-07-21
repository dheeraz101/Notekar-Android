import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:notekar/l10n/app_localizations.dart';
import 'package:notekar/screens/note_kar_home.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Parallelize core initialization
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    AdaptiveEngine().initialize(),
    _initHivePreload(),
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(NoteKarApp(prefs: results[0] as SharedPreferences));
}

Future<void> _initHivePreload() async {
  const channel = MethodChannel('notekar/files');
  try {
    final dataDir = await channel.invokeMethod<String>('appDataDir');
    Hive.init(dataDir ?? Directory.systemTemp.path);
  } catch (_) {
    Hive.init(Directory.systemTemp.path);
  }
}

class NoteKarApp extends StatefulWidget {
  const NoteKarApp({super.key, this.prefs});

  final SharedPreferences? prefs;

  static NoteKarAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<NoteKarAppState>();

  @override
  State<NoteKarApp> createState() => NoteKarAppState();
}

class NoteKarAppState extends State<NoteKarApp> {
  late String _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.prefs?.getString('m-locale') ?? 'system';
  }

  void setLocale(String locale) {
    setState(() {
      _locale = locale;
    });
    widget.prefs?.setString('m-locale', locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteKar',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale == 'system' ? null : Locale(_locale),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A84FF),
          brightness: Brightness.dark,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0A84FF),
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0A84FF),
          ),
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontVariations: [FontVariation('wght', 400)]),
          bodyMedium: TextStyle(fontVariations: [FontVariation('wght', 400)]),
          titleLarge: TextStyle(fontVariations: [FontVariation('wght', 600)]),
        ),
        splashFactory: NoSplash.splashFactory,
      ),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final clampedScaler = media.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.25,
        );

        return MediaQuery(
          data: media.copyWith(textScaler: clampedScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: NoteKarHome(preloadedPrefs: widget.prefs),
    );
  }
}
