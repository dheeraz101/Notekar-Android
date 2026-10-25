import 'dart:convert';

import 'package:notekar/models/peer_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing the single imported peer profile for horizon comparison.
class PeerProfileService {
  PeerProfileService._();

  static final PeerProfileService instance = PeerProfileService._();

  static const String _kPeerProfileKey = 'notekar.saved_peer_profile_v1';

  SharedPreferences? _prefs;

  Future<void> initialize({SharedPreferences? preloadedPrefs}) async {
    _prefs = preloadedPrefs ?? await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Returns the currently saved peer profile, if one exists.
  Future<PeerProfile?> getSavedPeerProfile() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_kPeerProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return PeerProfile.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously returns saved peer profile if prefs already available.
  PeerProfile? getSavedPeerProfileSync() {
    if (_prefs == null) return null;
    final raw = _prefs!.getString(_kPeerProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return PeerProfile.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Saves the peer profile, replacing any existing peer profile.
  Future<void> savePeerProfile(PeerProfile profile) async {
    final prefs = await _getPrefs();
    final encoded = jsonEncode(profile.toJson());
    await prefs.setString(_kPeerProfileKey, encoded);
  }

  /// Clears the saved peer profile.
  Future<void> clearPeerProfile() async {
    final prefs = await _getPrefs();
    await prefs.remove(_kPeerProfileKey);
  }

  /// Checks whether a peer profile is currently saved.
  Future<bool> hasSavedPeerProfile() async {
    final profile = await getSavedPeerProfile();
    return profile != null;
  }
}
