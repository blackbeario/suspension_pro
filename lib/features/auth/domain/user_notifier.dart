import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/features/auth/domain/models/user.dart';
import 'package:ridemetrx/features/auth/domain/user_state.dart';

part 'user_notifier.g.dart';

/// StateNotifier for managing user state
/// Replaces the UserSingleton pattern with proper Riverpod state management
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UserState build() {
    // Initialize with empty state (logged out)
    return UserState.empty();
  }

  /// Set user from AppUser model
  void setUser(AppUser user) {
    state = UserState.fromAppUser(user);
  }

  /// Update user profile information (local state only)
  void updateProfile({
    required String userName,
    required String firstName,
    required String lastName,
  }) {
    state = state.copyWith(
      userName: userName,
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Update user profile and sync to Firebase
  Future<void> updateProfileAndSync({
    required String userName,
    required String firstName,
    required String lastName,
  }) async {
    // Update local state immediately
    updateProfile(
      userName: userName,
      firstName: firstName,
      lastName: lastName,
    );

    // Sync to Firebase
    try {
      final db = ref.read(databaseServiceProvider);
      await db.updateUser(
        userName,
        firstName,
        lastName,
        state.email,
      );
      print('UserNotifier: Profile updated and synced to Firebase');
    } catch (e) {
      print('UserNotifier: Failed to sync profile to Firebase: $e');
      // Note: Local state is already updated, so UI will show new values
      // Failed Firebase sync can be retried later
    }
  }

  /// Update profile picture
  void updateProfilePic(String profilePic) {
    state = state.copyWith(profilePic: profilePic);
  }

  /// Update AI credits
  void updateAiCredits(int credits) {
    state = state.copyWith(aiCredits: credits);
  }

  /// Reset user state (logout)
  void logout() {
    state = UserState.empty();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state.isAuthenticated;

  /// Get current user ID
  String get uid => state.uid;
}
