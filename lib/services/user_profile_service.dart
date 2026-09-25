import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lifetime horizon metrics based on Date of Birth and Memento Mori life expectancy.
class LifeHorizonData {
  const LifeHorizonData({
    required this.hasDob,
    required this.exactAgeYears,
    required this.ageYears,
    required this.ageMonths,
    required this.targetYears,
    required this.remainingYears,
    required this.livedWeeks,
    required this.remainingWeeks,
    required this.totalWeeks,
    required this.livedPercentage,
    this.lifeClockFormatted = '06:00 AM',
    this.lifeClockTimeOfDay = 'Dawn',
    this.remainingConsciousYears = 0.0,
    this.remainingConsciousWeeks = 0,
    this.oneHourDailyLeverageYears = 0.0,
  });

  final bool hasDob;
  final double exactAgeYears;
  final int ageYears;
  final int ageMonths;
  final int targetYears;
  final double remainingYears;
  final int livedWeeks;
  final int remainingWeeks;
  final int totalWeeks;
  final double livedPercentage;
  final String lifeClockFormatted;
  final String lifeClockTimeOfDay;
  final double remainingConsciousYears;
  final int remainingConsciousWeeks;
  final double oneHourDailyLeverageYears;
}

/// Breakdown of conscious focus vs claimed rest vs untracked horizon.
class ProductivityBreakdownData {
  const ProductivityBreakdownData({
    required this.periodTotal,
    required this.trackedFocus,
    required this.claimedRest,
    required this.untrackedOrWasted,
    required this.focusPercentage,
    required this.restPercentage,
    required this.untrackedPercentage,
  });

  final Duration periodTotal;
  final Duration trackedFocus;
  final Duration claimedRest;
  final Duration untrackedOrWasted;
  final double focusPercentage;
  final double restPercentage;
  final double untrackedPercentage;
}

/// Service managing user profile, DOB, avatar, and Memento Mori life horizon.
class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  static const String keyUserName = 'user_profile_name';
  static const String keyUserDob = 'user_profile_dob';
  static const String keyUserAvatarBase64 = 'user_profile_avatar_base64';
  static const String keyUserPresetAvatar = 'user_profile_preset_avatar';
  static const String keyMementoMoriYears = 'user_memento_mori_years';
  static const String keyOnboardingCompleted = 'user_profile_onboarding_done';

  /// Maximum life expectancy cap for Memento Mori
  static const int maxMementoMoriYears = 100;
  static const int defaultMementoMoriYears = 80;

  /// Curated Apple-styled minimal preset emojis for avatars
  static const List<String> presetAvatars = [
    '⚡',
    '🦊',
    '🚀',
    '🧘',
    '🌿',
    '🎯',
    '☕',
    '🎨',
    '💎',
    '🏔️',
    '🦉',
    '🌟',
  ];

  String _name = '';
  DateTime? _dob;
  String? _avatarBase64;
  Uint8List? _avatarBytes;
  int? _presetAvatarIndex;
  int _mementoMoriYears = defaultMementoMoriYears;
  bool _onboardingCompleted = false;
  bool _loaded = false;

  String get name => _name;
  DateTime? get dob => _dob;
  String? get avatarBase64 => _avatarBase64;
  Uint8List? get avatarBytes => _avatarBytes;
  int? get presetAvatarIndex => _presetAvatarIndex;
  int get mementoMoriYears => _mementoMoriYears;
  bool get isOnboardingCompleted => _onboardingCompleted;
  bool get isLoaded => _loaded;

  Future<void> loadProfile({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    _name = p.getString(keyUserName) ?? '';
    final dobStr = p.getString(keyUserDob);
    if (dobStr != null && dobStr.isNotEmpty) {
      _dob = DateTime.tryParse(dobStr);
    }
    _avatarBase64 = p.getString(keyUserAvatarBase64);
    if (_avatarBase64 != null && _avatarBase64!.isNotEmpty) {
      try {
        _avatarBytes = base64Decode(_avatarBase64!);
      } catch (_) {
        _avatarBytes = null;
      }
    }
    _presetAvatarIndex = p.containsKey(keyUserPresetAvatar)
        ? p.getInt(keyUserPresetAvatar)
        : null;
    final savedYears = p.getInt(keyMementoMoriYears) ?? defaultMementoMoriYears;
    _mementoMoriYears = savedYears.clamp(1, maxMementoMoriYears);
    _onboardingCompleted = p.getBool(keyOnboardingCompleted) ?? false;
    _loaded = true;
    notifyListeners();
  }

  /// Directly updates the user avatar (custom image or preset) and notifies listeners immediately.
  Future<void> updateAvatar({
    Uint8List? customAvatarBytes,
    int? presetIndex,
    SharedPreferences? prefs,
  }) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    if (customAvatarBytes != null && customAvatarBytes.isNotEmpty) {
      _avatarBytes = customAvatarBytes;
      _avatarBase64 = base64Encode(customAvatarBytes);
      _presetAvatarIndex = null;
      await p.setString(keyUserAvatarBase64, _avatarBase64!);
      await p.remove(keyUserPresetAvatar);
    } else if (presetIndex != null) {
      _presetAvatarIndex = presetIndex;
      _avatarBytes = null;
      _avatarBase64 = null;
      await p.setInt(keyUserPresetAvatar, presetIndex);
      await p.remove(keyUserAvatarBase64);
    } else {
      _avatarBytes = null;
      _avatarBase64 = null;
      _presetAvatarIndex = null;
      await p.remove(keyUserAvatarBase64);
      await p.remove(keyUserPresetAvatar);
    }
    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    DateTime? dob,
    Uint8List? customAvatarBytes,
    int? presetIndex,
    int? mementoMoriYears,
    bool completeOnboarding = true,
    SharedPreferences? prefs,
  }) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    _name = name.trim();
    _dob = dob;

    if (customAvatarBytes != null && customAvatarBytes.isNotEmpty) {
      _avatarBytes = customAvatarBytes;
      _avatarBase64 = base64Encode(customAvatarBytes);
      _presetAvatarIndex = null;
      await p.setString(keyUserAvatarBase64, _avatarBase64!);
      await p.remove(keyUserPresetAvatar);
    } else if (presetIndex != null) {
      _presetAvatarIndex = presetIndex;
      _avatarBytes = null;
      _avatarBase64 = null;
      await p.setInt(keyUserPresetAvatar, presetIndex);
      await p.remove(keyUserAvatarBase64);
    }

    if (mementoMoriYears != null) {
      _mementoMoriYears = mementoMoriYears.clamp(1, maxMementoMoriYears);
      await p.setInt(keyMementoMoriYears, _mementoMoriYears);
    }

    await p.setString(keyUserName, _name);
    if (_dob != null) {
      await p.setString(keyUserDob, _dob!.toIso8601String());
    } else {
      await p.remove(keyUserDob);
    }

    if (completeOnboarding) {
      _onboardingCompleted = true;
      await p.setBool(keyOnboardingCompleted, true);
    }

    notifyListeners();
  }

  /// Calculates exact age, lived weeks, remaining horizon, and lived ratio.
  LifeHorizonData calculateLifeHorizon({DateTime? asOf}) {
    if (_dob == null) {
      return LifeHorizonData(
        hasDob: false,
        exactAgeYears: 0,
        ageYears: 0,
        ageMonths: 0,
        targetYears: _mementoMoriYears,
        remainingYears: _mementoMoriYears.toDouble(),
        livedWeeks: 0,
        remainingWeeks: (_mementoMoriYears * 52.1775).round(),
        totalWeeks: (_mementoMoriYears * 52.1775).round(),
        livedPercentage: 0.0,
      );
    }

    final now = asOf ?? DateTime.now();
    final dob = _dob!;
    final difference = now.difference(dob);
    final daysLived = difference.inDays.clamp(0, 36500);

    final exactAgeYears = daysLived / 365.2425;
    final ageYears = exactAgeYears.floor();
    final ageMonths = ((exactAgeYears - ageYears) * 12).round();

    final int targetYears = ageYears >= maxMementoMoriYears
        ? ageYears
        : _mementoMoriYears
              .clamp(math.max(1, ageYears), maxMementoMoriYears)
              .toInt();
    final totalDays = (targetYears * 365.2425).round();
    final remainingDays = math.max(0, totalDays - daysLived);
    final remainingYears = remainingDays / 365.2425;

    final livedWeeks = daysLived ~/ 7;
    final totalWeeks = totalDays ~/ 7;
    final remainingWeeks = math.max(0, totalWeeks - livedWeeks);

    final livedPercentage = totalDays > 0
        ? (daysLived / totalDays).clamp(0.0, 1.0)
        : 0.0;

    final lifeFraction = targetYears > 0
        ? (exactAgeYears / targetYears).clamp(0.0, 1.0)
        : 0.0;
    final totalClockMinutes = (lifeFraction * 24 * 60).round();
    final clockHours24 = (totalClockMinutes ~/ 60) % 24;
    final clockMinutes = totalClockMinutes % 60;
    final isPm = clockHours24 >= 12;
    final clockHours12 = clockHours24 == 0
        ? 12
        : (clockHours24 > 12 ? clockHours24 - 12 : clockHours24);
    final String lifeClockFormatted =
        '${clockHours12.toString().padLeft(2, '0')}:${clockMinutes.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
    final String lifeClockTimeOfDay = clockHours24 < 6
        ? 'Dawn'
        : (clockHours24 < 12
              ? 'Morning'
              : (clockHours24 < 17
                    ? 'Afternoon'
                    : (clockHours24 < 21 ? 'Evening' : 'Night')));

    const consciousAwakeRatio = 14.0 / 24.0;
    final remainingConsciousYears = remainingYears * consciousAwakeRatio;
    final remainingConsciousWeeks = (remainingWeeks * consciousAwakeRatio)
        .round();
    final oneHourDailyLeverageYears = remainingYears / 14.0;

    return LifeHorizonData(
      hasDob: true,
      exactAgeYears: exactAgeYears,
      ageYears: ageYears,
      ageMonths: ageMonths,
      targetYears: targetYears,
      remainingYears: remainingYears,
      livedWeeks: livedWeeks,
      remainingWeeks: remainingWeeks,
      totalWeeks: totalWeeks,
      livedPercentage: livedPercentage,
      lifeClockFormatted: lifeClockFormatted,
      lifeClockTimeOfDay: lifeClockTimeOfDay,
      remainingConsciousYears: remainingConsciousYears,
      remainingConsciousWeeks: remainingConsciousWeeks,
      oneHourDailyLeverageYears: oneHourDailyLeverageYears,
    );
  }

  /// Calculates conscious focus vs rest vs untracked hours in a given timeframe.
  ProductivityBreakdownData calculateProductivity({
    required List<Moment> entries,
    required DateTime start,
    required DateTime end,
  }) {
    final periodDuration = end.difference(start);
    final periodMs = math.max(1, periodDuration.inMilliseconds);

    int focusMs = 0;
    int restMs = 0;

    // Filter moments in this window and sort chronologically
    final relevant = entries.where((m) {
      final dt = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
      return dt.isAfter(start) && dt.isBefore(end);
    }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Group sessions
    Moment? openIn;
    for (final m in relevant) {
      final cat = CategoryService.extractCategory(m) ?? 'General';
      final isRest =
          cat.toLowerCase() == 'rest' ||
          cat.toLowerCase() == 'sleep' ||
          cat.toLowerCase() == 'recovery';

      if (m.type == 'in') {
        openIn = m;
      } else if (m.type == 'out' && openIn != null) {
        final dur = math.max(0, m.timestamp - openIn.timestamp);
        if (dur < 24 * 3600 * 1000) {
          if (isRest) {
            restMs += dur;
          } else {
            focusMs += dur;
          }
        }
        openIn = null;
      } else if (m.type == 'single') {
        const singleMs = 15 * 60 * 1000;
        if (isRest) {
          restMs += singleMs;
        } else {
          focusMs += singleMs;
        }
      }
    }

    final trackedMs = focusMs + restMs;
    final untrackedMs = math.max(0, periodMs - trackedMs);

    return ProductivityBreakdownData(
      periodTotal: periodDuration,
      trackedFocus: Duration(milliseconds: focusMs),
      claimedRest: Duration(milliseconds: restMs),
      untrackedOrWasted: Duration(milliseconds: untrackedMs),
      focusPercentage: (focusMs / periodMs).clamp(0.0, 1.0),
      restPercentage: (restMs / periodMs).clamp(0.0, 1.0),
      untrackedPercentage: (untrackedMs / periodMs).clamp(0.0, 1.0),
    );
  }

  /// Renders a profile avatar with Apple HIG styling.
  Widget buildAvatarWidget({
    required Palette p,
    double size = 44,
    bool showBorder = true,
  }) {
    Widget content;
    if (_avatarBytes != null && _avatarBytes!.isNotEmpty) {
      content = Image.memory(
        _avatarBytes!,
        key: ValueKey(_avatarBytes.hashCode),
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackMonogram(p, size),
      );
    } else if (_presetAvatarIndex != null &&
        _presetAvatarIndex! >= 0 &&
        _presetAvatarIndex! < presetAvatars.length) {
      content = Center(
        child: Text(
          presetAvatars[_presetAvatarIndex!],
          style: TextStyle(fontSize: size * 0.52),
        ),
      );
    } else if (_name.trim().isNotEmpty) {
      content = _buildFallbackMonogram(p, size);
    } else {
      content = Center(
        child: Icon(
          CupertinoIcons.person_fill,
          size: size * 0.52,
          color: p.accent,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
          ClipOval(child: SizedBox.expand(child: content)),
          if (showBorder)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: p.accent.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackMonogram(Palette p, double size) {
    final initial = _name.trim().isNotEmpty
        ? _name.trim()[0].toUpperCase()
        : 'U';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: p.accent,
          fontSize: size * 0.44,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
