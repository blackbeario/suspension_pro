import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:suspension_pro/core/providers/service_providers.dart';
import 'package:suspension_pro/features/auth/domain/user_notifier.dart';
import 'package:suspension_pro/features/connectivity/domain/connectivity_notifier.dart';

part 'auth_view_model.g.dart';

/// State for authentication operations
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? errorDetails;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.errorDetails,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? errorDetails,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      errorDetails: errorDetails,
    );
  }

  /// Clear error state
  AuthState clearError() {
    return AuthState(isLoading: isLoading);
  }
}

/// ViewModel for authentication operations
/// Handles login, signup, and logout with both Firebase and Hive
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() {
    return const AuthState();
  }

  /// Sign in with Firebase (online) or Hive (offline)
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    state = state.clearError();

    try {
      final authService = ref.read(authServiceProvider);
      final isConnected = ref.read(connectivityNotifierProvider);

      if (isConnected) {
        // Online: Sign in with Firebase
        final result = await authService.signInWithFirebase(email, password);

        if (result is FirebaseAuthException) {
          state = AuthState(
            isLoading: false,
            errorMessage: result.code,
            errorDetails: result.message,
          );
          return;
        }

        if (result is User) {
          // Success - router will redirect based on userNotifier state
          state = const AuthState(isLoading: false);
        }
      } else {
        // Offline: Sign in with Hive
        final result = await authService.signInWithHive(email, password);

        if (result is PlatformException) {
          state = AuthState(
            isLoading: false,
            errorMessage: result.message ?? 'Login failed',
            errorDetails: result.details?.toString(),
          );
          return;
        }

        // Success
        state = const AuthState(isLoading: false);
      }
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
        errorDetails: e.toString(),
      );
    }
  }

  /// Create a new Firebase user account
  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true);
    state = state.clearError();

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.createFirebaseUser(email, password);

      if (result is String) {
        // Error message returned
        state = AuthState(
          isLoading: false,
          errorMessage: 'Sign up failed',
          errorDetails: result,
        );
        return;
      }

      if (result is User) {
        // Success - router will redirect
        state = const AuthState(isLoading: false);
      }
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
        errorDetails: e.toString(),
      );
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      // Reset user state
      ref.read(userNotifierProvider.notifier).logout();

      state = const AuthState(isLoading: false);
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: 'Sign out failed',
        errorDetails: e.toString(),
      );
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.clearError();
  }
}

/// Provider to listen to Firebase auth state changes
@riverpod
Stream<User?> firebaseAuthState(FirebaseAuthStateRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.user;
}
