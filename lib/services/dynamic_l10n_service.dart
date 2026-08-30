import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:notekar/l10n/l10n_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePackInfo {
  const LanguagePackInfo({
    required this.code,
    required this.name,
    required this.englishName,
    required this.flag,
    required this.version,
    required this.sizeKb,
    required this.translatedPercent,
    required this.description,
  });

  factory LanguagePackInfo.fromJson(Map<String, dynamic> json) {
    return LanguagePackInfo(
      code: json['code'] as String,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      flag: json['flag'] as String,
      version: json['version'] as int? ?? 1,
      sizeKb: json['sizeKb'] as int? ?? 45,
      translatedPercent: json['translatedPercent'] as int? ?? 100,
      description: json['description'] as String? ?? '',
    );
  }

  final String code;
  final String name;
  final String englishName;
  final String flag;
  final int version;
  final int sizeKb;
  final int translatedPercent;
  final String description;
}

class DynamicL10nService {
  DynamicL10nService._();

  static final DynamicL10nService instance = DynamicL10nService._();

  static const String _baseUrl =
      'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/main/lib/l10n/packages';

  String? _storageDirPath;
  final Map<String, Map<String, String>> _loadedTranslations = {};
  final Set<String> _downloadedCodes = {};
  List<LanguagePackInfo> _catalog = [];

  List<LanguagePackInfo> get catalog => _catalog;

  Future<void> initialize(SharedPreferences prefs) async {
    // Determine storage directory
    try {
      const channel = MethodChannel('notekar/files');
      final appDir = await channel.invokeMethod<String>('appDataDir');
      if (appDir != null) {
        final dir = Directory('$appDir/l10n');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        _storageDirPath = dir.path;
      }
    } catch (_) {}

    // Load tracked downloaded codes
    final downloadedList =
        prefs.getStringList('downloaded_l10n_packs') ?? <String>[];
    _downloadedCodes.clear();
    _downloadedCodes.addAll(downloadedList);

    // Verify downloaded files physically exist if storage directory is set
    if (_storageDirPath != null) {
      final toRemove = <String>[];
      for (final code in _downloadedCodes) {
        final file = File('$_storageDirPath/$code.json');
        if (!file.existsSync()) {
          toRemove.add(code);
        }
      }
      if (toRemove.isNotEmpty) {
        _downloadedCodes.removeAll(toRemove);
        await prefs.setStringList(
          'downloaded_l10n_packs',
          _downloadedCodes.toList(),
        );
      }
    }

    // Load available languages catalog from embedded asset
    try {
      final catalogString = await rootBundle.loadString(
        'lib/l10n/packages/languages.json',
      );
      final List<dynamic> list = jsonDecode(catalogString) as List<dynamic>;
      _catalog = list
          .map((e) => LanguagePackInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _catalog = const [
        LanguagePackInfo(
          code: 'fr',
          name: 'Français',
          englishName: 'French',
          flag: '🇫🇷',
          version: 1,
          sizeKb: 42,
          translatedPercent: 100,
          description: 'French localization for NoteKar',
        ),
        LanguagePackInfo(
          code: 'es',
          name: 'Español',
          englishName: 'Spanish',
          flag: '🇪🇸',
          version: 1,
          sizeKb: 44,
          translatedPercent: 100,
          description: 'Spanish localization for NoteKar',
        ),
        LanguagePackInfo(
          code: 'hi',
          name: 'हिन्दी',
          englishName: 'Hindi',
          flag: '🇮🇳',
          version: 1,
          sizeKb: 48,
          translatedPercent: 100,
          description: 'Hindi localization for NoteKar',
        ),
        LanguagePackInfo(
          code: 'de',
          name: 'Deutsch',
          englishName: 'German',
          flag: '🇩🇪',
          version: 1,
          sizeKb: 45,
          translatedPercent: 100,
          description: 'German localization for NoteKar',
        ),
        LanguagePackInfo(
          code: 'ja',
          name: '日本語',
          englishName: 'Japanese',
          flag: '🇯🇵',
          version: 1,
          sizeKb: 52,
          translatedPercent: 100,
          description: 'Japanese localization for NoteKar',
        ),
        LanguagePackInfo(
          code: 'ru',
          name: 'Русский',
          englishName: 'Russian',
          flag: '🇷🇺',
          version: 1,
          sizeKb: 50,
          translatedPercent: 100,
          description: 'Russian localization for NoteKar',
        ),
      ];
    }

    // Preload active locale translation if downloaded
    final activeLocale = prefs.getString('m-locale') ?? 'system';
    if (activeLocale != 'en' && activeLocale != 'system') {
      if (isDownloaded(activeLocale)) {
        await loadLanguage(activeLocale);
      } else {
        // If active locale is not downloaded, revert to English
        await prefs.setString('m-locale', 'en');
      }
    }
  }

  bool isDownloaded(String code) {
    if (code == 'en' || code == 'system') return true;
    if (!_downloadedCodes.contains(code)) return false;
    if (_storageDirPath != null) {
      final file = File('$_storageDirPath/$code.json');
      return file.existsSync();
    }
    return true;
  }

  Future<bool> loadLanguage(String code) async {
    if (code == 'en' || code == 'system') return true;
    if (_loadedTranslations.containsKey(code)) return true;

    // 1. Read from local storage
    if (_storageDirPath != null) {
      final file = File('$_storageDirPath/$code.json');
      if (file.existsSync()) {
        try {
          final content = await file.readAsString();
          final map = jsonDecode(content) as Map<String, dynamic>;
          _loadedTranslations[code] = map.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          );
          return true;
        } catch (_) {}
      }
    }

    // 2. Fallback to bundled translations
    if (kL10nTranslations.containsKey(code)) {
      _loadedTranslations[code] = Map<String, String>.from(
        kL10nTranslations[code]!,
      );
      return true;
    }

    return false;
  }

  Future<bool> downloadLanguage(
    String code, {
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.2);
    try {
      String? jsonContent;

      // 1. Attempt remote download from GitHub Raw CDN
      try {
        final url = Uri.parse('$_baseUrl/$code.json');
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
          jsonContent = response.body;
        }
      } catch (_) {}

      onProgress?.call(0.6);

      // 2. Fallback to bundled package asset if offline
      try {
        jsonContent ??= await rootBundle.loadString(
          'lib/l10n/packages/$code.json',
        );
      } catch (_) {}

      // 3. Fallback to in-memory dictionary if package asset is unavailable
      if ((jsonContent == null || jsonContent.isEmpty) &&
          kL10nTranslations.containsKey(code)) {
        _loadedTranslations[code] = Map<String, String>.from(
          kL10nTranslations[code]!,
        );
        jsonContent = jsonEncode(_loadedTranslations[code]);
      }

      // 4. Save to local app storage
      if (_storageDirPath != null && jsonContent != null) {
        final file = File('$_storageDirPath/$code.json');
        await file.writeAsString(jsonContent);
      }

      if (jsonContent != null &&
          jsonContent.isNotEmpty &&
          !_loadedTranslations.containsKey(code)) {
        final map = jsonDecode(jsonContent) as Map<String, dynamic>;
        _loadedTranslations[code] = map.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }

      // 5. Mark downloaded in cache and prefs
      _downloadedCodes.add(code);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'downloaded_l10n_packs',
        _downloadedCodes.toList(),
      );

      onProgress?.call(1.0);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteLanguage(String code, SharedPreferences prefs) async {
    _loadedTranslations.remove(code);
    _downloadedCodes.remove(code);
    await prefs.setStringList(
      'downloaded_l10n_packs',
      _downloadedCodes.toList(),
    );

    if (_storageDirPath != null) {
      final file = File('$_storageDirPath/$code.json');
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
    }

    // Revert to English if the active locale was deleted
    final currentLocale = prefs.getString('m-locale') ?? 'system';
    if (currentLocale == code) {
      await prefs.setString('m-locale', 'en');
    }
  }

  String? lookup(String locale, String key) {
    if (locale == 'en' || locale == 'system') return null;
    if (!isDownloaded(locale)) return null;

    final normalized = key.trim().toLowerCase();

    // Check loaded dynamic translations
    final dynamicMap = _loadedTranslations[locale];
    if (dynamicMap != null && dynamicMap.containsKey(normalized)) {
      return dynamicMap[normalized];
    }

    // Fallback to static dictionary if downloaded
    final staticMap = kL10nTranslations[locale];
    if (staticMap != null && staticMap.containsKey(normalized)) {
      return staticMap[normalized];
    }

    return null;
  }
}
