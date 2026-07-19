import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/screens/note_kar_home.dart';
import 'package:notekar/utils/adaptive_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdaptiveEngine().initialize();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NoteKarApp());
}

class NoteKarApp extends StatelessWidget {
  const NoteKarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteKar',
      debugShowCheckedModeBanner: false,
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
      home: const NoteKarHome(),
    );
  }
}
