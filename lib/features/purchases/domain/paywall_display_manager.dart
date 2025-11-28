import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages when and how often the paywall should be displayed to users
/// Ensures we don't annoy users with too-frequent paywall prompts
class PaywallDisplayManager {
  static const String _keyLastShown = 'paywall_last_shown';
  static const String _keyDismissCount = 'paywall_dismiss_count';

  // Display strategy constants
  static const int _minDaysBetweenShows = 7; // Don't show more than once per week
  static const int _maxDismissBeforePause = 2; // After 2 dismissals, pause for longer
  static const int _extendedPauseDays = 14; // 14 days pause after multiple dismissals

  /// Check if we should show the paywall to the current user
  /// Returns true if enough time has passed and user isn't Pro
  static Future<bool> shouldShowPaywall({
    required bool isPro,
    required bool hasNoBikes,
  }) async {
    // Never show to Pro users
    if (isPro) return false;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final userId = currentUser.uid;

    final lastShownKey = '${_keyLastShown}_$userId';
    final dismissCountKey = '${_keyDismissCount}_$userId';

    final lastShownTimestamp = prefs.getInt(lastShownKey);
    final dismissCount = prefs.getInt(dismissCountKey) ?? 0;

    // First time user with no bikes - always show
    if (lastShownTimestamp == null && hasNoBikes) {
      return true;
    }

    // Never shown before and has bikes - show it once
    if (lastShownTimestamp == null) {
      return true;
    }

    // Calculate days since last shown
    final lastShown = DateTime.fromMillisecondsSinceEpoch(lastShownTimestamp);
    final daysSinceLastShown = DateTime.now().difference(lastShown).inDays;

    // If dismissed multiple times, require longer pause
    if (dismissCount >= _maxDismissBeforePause) {
      return daysSinceLastShown >= _extendedPauseDays;
    }

    // Normal case: show if minimum days have passed
    return daysSinceLastShown >= _minDaysBetweenShows;
  }

  /// Record that the paywall was shown
  static Future<void> recordPaywallShown() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = currentUser.uid;

    final lastShownKey = '${_keyLastShown}_$userId';
    await prefs.setInt(lastShownKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Record that the user dismissed the paywall
  static Future<void> recordPaywallDismissed() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = currentUser.uid;

    final lastShownKey = '${_keyLastShown}_$userId';
    final dismissCountKey = '${_keyDismissCount}_$userId';

    // Update last shown time
    await prefs.setInt(lastShownKey, DateTime.now().millisecondsSinceEpoch);

    // Increment dismiss count
    final currentCount = prefs.getInt(dismissCountKey) ?? 0;
    await prefs.setInt(dismissCountKey, currentCount + 1);

    print('PaywallDisplayManager: User dismissed paywall (count: ${currentCount + 1})');
  }

  /// Reset paywall tracking (e.g., when user subscribes)
  static Future<void> resetPaywallTracking() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = currentUser.uid;

    final lastShownKey = '${_keyLastShown}_$userId';
    final dismissCountKey = '${_keyDismissCount}_$userId';

    await prefs.remove(lastShownKey);
    await prefs.remove(dismissCountKey);

    print('PaywallDisplayManager: Reset tracking for user');
  }

  /// Get info about paywall display status (for debugging)
  static Future<Map<String, dynamic>> getDisplayStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return {'error': 'No user logged in'};
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = currentUser.uid;

    final lastShownKey = '${_keyLastShown}_$userId';
    final dismissCountKey = '${_keyDismissCount}_$userId';

    final lastShownTimestamp = prefs.getInt(lastShownKey);
    final dismissCount = prefs.getInt(dismissCountKey) ?? 0;

    if (lastShownTimestamp == null) {
      return {
        'never_shown': true,
        'dismiss_count': dismissCount,
      };
    }

    final lastShown = DateTime.fromMillisecondsSinceEpoch(lastShownTimestamp);
    final daysSinceLastShown = DateTime.now().difference(lastShown).inDays;

    return {
      'last_shown': lastShown.toIso8601String(),
      'days_since_last_shown': daysSinceLastShown,
      'dismiss_count': dismissCount,
      'min_days_between_shows': dismissCount >= _maxDismissBeforePause
          ? _extendedPauseDays
          : _minDaysBetweenShows,
    };
  }
}
