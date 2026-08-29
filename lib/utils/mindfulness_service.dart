import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MindfulnessService {
  MindfulnessService._();

  static final MindfulnessService instance = MindfulnessService._();

  static const String keyEnabled = 'reminder_reflection_enabled';
  static const String keyIntervalMins = 'reminder_reflection_interval_mins';
  static const String keySound = 'reminder_reflection_sound';
  static const String keyBody = 'reminder_reflection_body';
  static const String keyStartHour = 'reminder_reflection_start_hour';
  static const String keyStartMinute = 'reminder_reflection_start_minute';
  static const String keyEndHour = 'reminder_reflection_end_hour';
  static const String keyEndMinute = 'reminder_reflection_end_minute';

  static const MethodChannel _remindersChannel = MethodChannel(
    'notekar/reminders',
  );

  bool isEnabled(SharedPreferences prefs) => prefs.getBool(keyEnabled) ?? false;

  int getIntervalMins(SharedPreferences prefs) =>
      prefs.getInt(keyIntervalMins) ?? 60;

  bool isSoundEnabled(SharedPreferences prefs) =>
      prefs.getBool(keySound) ?? true;

  String getCustomMessage(SharedPreferences prefs) =>
      prefs.getString(keyBody) ?? '';

  TimeOfDay getStartTime(SharedPreferences prefs) {
    final h = prefs.getInt(keyStartHour) ?? 9;
    final m = prefs.getInt(keyStartMinute) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  TimeOfDay getEndTime(SharedPreferences prefs) {
    final h = prefs.getInt(keyEndHour) ?? 22;
    final m = prefs.getInt(keyEndMinute) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  bool isWithinActiveHours(TimeOfDay now, TimeOfDay start, TimeOfDay end) {
    final nowMins = now.hour * 60 + now.minute;
    final startMins = start.hour * 60 + start.minute;
    final endMins = end.hour * 60 + end.minute;

    if (startMins <= endMins) {
      return nowMins >= startMins && nowMins <= endMins;
    } else {
      // Crosses midnight (e.g. 20:00 to 06:00)
      return nowMins >= startMins || nowMins <= endMins;
    }
  }

  Future<void> syncReflectionReminder(SharedPreferences prefs) async {
    final enabled = isEnabled(prefs);
    if (!enabled) {
      await cancelReflectionReminder();
      return;
    }

    final intervalMins = getIntervalMins(prefs);
    final startTime = getStartTime(prefs);
    final endTime = getEndTime(prefs);
    final message = getCustomMessage(prefs);
    final sound = isSoundEnabled(prefs);

    try {
      await _remindersChannel.invokeMethod<void>('scheduleReminder', {
        'id': 'reflection',
        'type': 'reflection',
        'intervalMinutes': intervalMins,
        'title': 'Time Reflection',
        'body': message.trim().isNotEmpty
            ? message.trim()
            : 'Pause. Breathe. Be present in this moment.',
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'endHour': endTime.hour,
        'endMinute': endTime.minute,
        'sound': sound,
      });
    } catch (_) {}
  }

  Future<void> cancelReflectionReminder() async {
    try {
      await _remindersChannel.invokeMethod<void>('cancelReminder', {
        'id': 'reflection',
      });
    } catch (_) {}
  }

  Future<void> scheduleTestAlert() async {
    try {
      await _remindersChannel.invokeMethod<void>('scheduleReminder', {
        'id': 'reflection_test',
        'type': 'reflection',
        'delaySeconds': 3,
        'title': 'Time Reflection',
        'body': 'Pause. Breathe. Be present in this moment.',
      });
    } catch (_) {}
  }
}
