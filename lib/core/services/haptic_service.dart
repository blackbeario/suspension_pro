import 'package:flutter/services.dart';

/// Centralized haptic feedback service for RideMetrx
///
/// Provides semantic methods for different haptic feedback patterns
/// following Apple's Human Interface Guidelines.
///
/// Usage:
/// ```dart
/// HapticService.light();    // Quick selections, taps, toggles
/// HapticService.medium();   // Confirmatory actions, form submissions
/// HapticService.heavy();    // Major transactions, completions
/// HapticService.warning();  // Destructive actions, errors
/// HapticService.success();  // Successful completions
/// HapticService.error();    // Validation errors, failures
/// ```
class HapticService {
  /// Light feedback for quick selections, taps, and toggles
  ///
  /// Use for:
  /// - Text field focus
  /// - Toggle switches
  /// - Navigation taps
  /// - Filter chip selections
  /// - Expansion tile toggles
  /// - Icon button taps
  static void light() {
    HapticFeedback.selectionClick();
  }

  /// Medium feedback for confirmatory actions and form submissions
  ///
  /// Use for:
  /// - Form submissions (save buttons)
  /// - Adding new items
  /// - List reordering
  /// - Swipe actions
  /// - Import/clone actions
  /// - Search executions
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy feedback for major transactions and completions
  ///
  /// Use for:
  /// - Purchase transactions
  /// - Restore purchases
  /// - Major wizard completions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Warning feedback for destructive actions and confirmations
  ///
  /// Use for:
  /// - Delete confirmations
  /// - Destructive action execution
  /// - Sign out confirmations
  /// - Reset confirmations
  static void warning() {
    HapticFeedback.vibrate();
  }

  /// Success feedback for successful completions
  ///
  /// Provides a rewarding two-tap pattern (medium + light)
  ///
  /// Use for:
  /// - Successful saves
  /// - Successful imports/clones
  /// - Purchase completions
  /// - Refresh completions
  static void success() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Error feedback for validation errors and failures
  ///
  /// Provides a distinct double-tap pattern (heavy + heavy)
  ///
  /// Use for:
  /// - Login/signup errors
  /// - Form validation failures
  /// - Network errors
  static void error() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.heavyImpact();
    });
  }
}
