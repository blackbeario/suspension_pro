// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseServiceHash() => r'8865fedf2ff3cfb3699eea6029d65f22c8eb148c';

/// Database Service Provider
/// Provides access to Firestore operations
/// Injects current user's uid from userNotifierProvider
///
/// Copied from [databaseService].
@ProviderFor(databaseService)
final databaseServiceProvider = AutoDisposeProvider<DatabaseService>.internal(
  databaseService,
  name: r'databaseServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseServiceRef = AutoDisposeProviderRef<DatabaseService>;
String _$authServiceHash() => r'82398d9f38c720e4ddf6b218248f15089fd4f178';

/// Auth Service Provider
/// Handles Firebase and Hive authentication
///
/// Copied from [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$hiveServiceHash() => r'9a3c04f5e3ba12b75b6539b2a85c574ab706653b';

/// Hive Service Provider
/// Manages local Hive database operations
///
/// Copied from [hiveService].
@ProviderFor(hiveService)
final hiveServiceProvider = AutoDisposeProvider<HiveService>.internal(
  hiveService,
  name: r'hiveServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hiveServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HiveServiceRef = AutoDisposeProviderRef<HiveService>;
String _$analyticsServiceHash() => r'bc02c9f2dac78875378bad38e1cd8f8b22d97a7d';

/// Analytics Service Provider
/// Provides Firebase Analytics logging
///
/// Copied from [analyticsService].
@ProviderFor(analyticsService)
final analyticsServiceProvider = AutoDisposeProvider<Analytics>.internal(
  analyticsService,
  name: r'analyticsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsServiceRef = AutoDisposeProviderRef<Analytics>;
String _$encryptionServiceHash() => r'0b1d3703b1e130056377c0ac40ab6c5cb707d82a';

/// Encryption Service Provider
/// Handles password encryption/decryption
///
/// Copied from [encryptionService].
@ProviderFor(encryptionService)
final encryptionServiceProvider =
    AutoDisposeProvider<EncryptionService>.internal(
  encryptionService,
  name: r'encryptionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$encryptionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EncryptionServiceRef = AutoDisposeProviderRef<EncryptionService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
