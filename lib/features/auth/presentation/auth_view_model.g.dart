// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthStateHash() => r'7c592ec3968104b53384a4b3c41b960db61c42e4';

/// Provider to listen to Firebase auth state changes
///
/// Copied from [firebaseAuthState].
@ProviderFor(firebaseAuthState)
final firebaseAuthStateProvider = AutoDisposeStreamProvider<User?>.internal(
  firebaseAuthState,
  name: r'firebaseAuthStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAuthStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$authViewModelHash() => r'8ac9eeb00b127a5a3a5ce1a173e06d88063aca7f';

/// ViewModel for authentication operations
/// Handles login, signup, and logout with both Firebase and Hive
///
/// Copied from [AuthViewModel].
@ProviderFor(AuthViewModel)
final authViewModelProvider =
    AutoDisposeNotifierProvider<AuthViewModel, AuthState>.internal(
  AuthViewModel.new,
  name: r'authViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthViewModel = AutoDisposeNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
