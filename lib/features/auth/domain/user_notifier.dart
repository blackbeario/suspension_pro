import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:suspension_pro/features/auth/domain/models/user.dart';
import 'package:suspension_pro/features/auth/domain/user_state.dart';

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

  /// Update user profile information
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
