import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:notekar/l10n/app_localizations.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/screens/note_kar_home.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPrefsFuture = SharedPreferences.getInstance();
  final hivePreloadFuture = _initHivePreload();

  final results = await Future.wait([sharedPrefsFuture, hivePreloadFuture]);

  final prefs = results[0] as SharedPreferences;
  unawaited(AdaptiveEngine().initialize(prefs: prefs));

  if (prefs.getBool('auto_delete_update_cache') ?? false) {
    unawaited(UpdateService().clearCachedBuilds());
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(NoteKarApp(prefs: prefs));
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
  late String _theme;
  late String _accent;
  late bool _highContrast;

  @override
  void initState() {
    super.initState();
    _locale = widget.prefs?.getString('m-locale') ?? 'system';
    _theme = widget.prefs?.getString('m-theme') ?? 'dark';
    _accent = widget.prefs?.getString('m-accent-color') ?? 'blue';
    _highContrast = widget.prefs?.getBool('m-high-contrast') ?? false;
    final obfuscate = widget.prefs?.getBool('obfuscate_in_recents') ?? false;
    if (obfuscate) {
      const MethodChannel(
        'notekar/files',
      ).invokeMethod<void>('setObfuscateInRecents', {'enabled': true});
    }
  }

  void setLocale(String locale) {
    setState(() {
      _locale = locale;
    });
    widget.prefs?.setString('m-locale', locale);
  }

  void setTheme(String theme) {
    if (_theme != theme) {
      setState(() => _theme = theme);
    }
  }

  void setAccent(String accent) {
    if (_accent != accent) {
      setState(() => _accent = accent);
    }
  }

  void setHighContrast(bool highContrast) {
    if (_highContrast != highContrast) {
      setState(() => _highContrast = highContrast);
    }
  }

  ThemeData _buildThemeData(String theme, String accent, bool highContrast) {
    final p = paletteFor(theme, accentName: accent, highContrast: highContrast);
    final isLight = theme == 'light';
    final isAmoled = theme == 'amoled';
    final brightness = isLight ? Brightness.light : Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: p.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p.accent,
        brightness: brightness,
        surface: p.surface2,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: p.border.withValues(alpha: isAmoled ? 0.8 : 0.4),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.accent,
          side: BorderSide(color: p.border),
        ),
      ),
      fontFamily: 'Inter',
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: p.text,
          fontVariations: const [FontVariation('wght', 400)],
        ),
        bodyMedium: TextStyle(
          color: p.text,
          fontVariations: const [FontVariation('wght', 400)],
        ),
        titleLarge: TextStyle(
          color: p.text,
          fontVariations: const [FontVariation('wght', 600)],
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: p.accent,
        scaffoldBackgroundColor: p.bg,
        barBackgroundColor: p.surface2,
        textTheme: CupertinoTextThemeData(
          primaryColor: p.accent,
          textStyle: TextStyle(fontFamily: 'Inter', color: p.text),
          actionTextStyle: TextStyle(
            fontFamily: 'Inter',
            color: p.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteKar',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale == 'system' ? null : Locale(_locale),
      themeMode: _theme == 'light' ? ThemeMode.light : ThemeMode.dark,
      theme: _buildThemeData(_theme, _accent, _highContrast),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final clampedScaler = media.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.20,
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
