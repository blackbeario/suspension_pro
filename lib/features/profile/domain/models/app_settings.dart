import 'package:flutter/foundation.dart';

/// Model for app-level user settings and preferences
@immutable
class AppSettings {
  final bool pushNotificationsEnabled;
  final bool autoDownloadCommunityPhotos;
  final bool enableAnalytics;

  const AppSettings({
    this.pushNotificationsEnabled = true,
    this.autoDownloadCommunityPhotos = false,
    this.enableAnalytics = true,
  });

  AppSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? autoDownloadCommunityPhotos,
    bool? enableAnalytics,
  }) {
    return AppSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      autoDownloadCommunityPhotos: autoDownloadCommunityPhotos ?? this.autoDownloadCommunityPhotos,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'autoDownloadCommunityPhotos': autoDownloadCommunityPhotos,
      'enableAnalytics': enableAnalytics,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
      autoDownloadCommunityPhotos: json['autoDownloadCommunityPhotos'] as bool? ?? false,
      enableAnalytics: json['enableAnalytics'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          pushNotificationsEnabled == other.pushNotificationsEnabled &&
          autoDownloadCommunityPhotos == other.autoDownloadCommunityPhotos &&
          enableAnalytics == other.enableAnalytics;

  @override
  int get hashCode =>
      pushNotificationsEnabled.hashCode ^
      autoDownloadCommunityPhotos.hashCode ^
      enableAnalytics.hashCode;
}
