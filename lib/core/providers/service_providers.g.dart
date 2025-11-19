// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseServiceHash() => r'dfc85031ab5065f7ed82c39dd1089a7f8087b5e8';

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
String _$authServiceHash() => r'e771c719cfb4bd87b7f15fc6722ef9f56a9844e4';

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
String _$hiveServiceHash() => r'8df37bcf610476ae55cb241c6cb79a2081550312';

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
String _$inAppPurchaseServiceHash() =>
    r'0c644eac404f27bd3fb939ab442dfefb7ef57a65';

/// In-App Purchase Service Provider
/// Handles purchase flow and verification
///
/// Copied from [inAppPurchaseService].
@ProviderFor(inAppPurchaseService)
final inAppPurchaseServiceProvider =
    AutoDisposeProvider<InAppPurchaseService>.internal(
  inAppPurchaseService,
  name: r'inAppPurchaseServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inAppPurchaseServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InAppPurchaseServiceRef = AutoDisposeProviderRef<InAppPurchaseService>;
String _$analyticsServiceHash() => r'58d82b4cf5c065cbeb7ea1ecaaaf3d5e9df7cc09';

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
String _$encryptionServiceHash() => r'35a23d4e9239075898a43f54cbe8d62e02f503d5';

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
