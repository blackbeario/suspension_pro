import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridemetrx/features/profile/domain/models/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

const String _kAppSettingsKey = 'app_settings';

/// Notifier for managing app-level user settings
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  AppSettingsNotifier(this._prefs) : super(const AppSettings()) {
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  void _loadSettings() {
    final settingsJson = _prefs.getString(_kAppSettingsKey);
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        state = AppSettings.fromJson(json);
      } catch (e) {
        // If there's an error loading settings, use defaults
        state = const AppSettings();
      }
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final settingsJson = jsonEncode(state.toJson());
    await _prefs.setString(_kAppSettingsKey, settingsJson);
  }

  /// Toggle push notifications and request permission if enabling
  Future<void> togglePushNotifications(bool enabled) async {
    if (enabled) {
      // Request permission when enabling
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Only update if permission was granted
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        state = state.copyWith(pushNotificationsEnabled: true);
        await _saveSettings();
      }
    } else {
      // When disabling, just update the preference
      // Note: We can't revoke iOS permissions from the app, user must do it in Settings
      state = state.copyWith(pushNotificationsEnabled: false);
      await _saveSettings();
    }
  }

  /// Toggle auto-download of community photos
  Future<void> toggleAutoDownloadCommunityPhotos(bool enabled) async {
    state = state.copyWith(autoDownloadCommunityPhotos: enabled);
    await _saveSettings();
  }

  /// Toggle analytics collection
  Future<void> toggleAnalytics(bool enabled) async {
    state = state.copyWith(enableAnalytics: enabled);
    await _saveSettings();
    // TODO: Update Firebase Analytics collection enabled state
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await _saveSettings();
  }
}

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main.dart');
});

/// Provider for AppSettingsNotifier
final appSettingsNotifierProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppSettingsNotifier(prefs);
});
