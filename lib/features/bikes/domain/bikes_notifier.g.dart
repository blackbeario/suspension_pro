// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bikes_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bikesStreamHash() => r'3628ca40a670a92b89153756ea2a9902deead48f';

/// Stream provider for bikes from Firestore
///
/// Copied from [bikesStream].
@ProviderFor(bikesStream)
final bikesStreamProvider = AutoDisposeStreamProvider<List<Bike>>.internal(
  bikesStream,
  name: r'bikesStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bikesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BikesStreamRef = AutoDisposeStreamProviderRef<List<Bike>>;
String _$offlineBikesHash() => r'd5e9f4d753532293dc3f6c8d26b461917fbf9365';

/// Provider for offline bikes from Hive (excludes deleted items)
///
/// Copied from [offlineBikes].
@ProviderFor(offlineBikes)
final offlineBikesProvider = AutoDisposeProvider<List<Bike>>.internal(
  offlineBikes,
  name: r'offlineBikesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$offlineBikesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineBikesRef = AutoDisposeProviderRef<List<Bike>>;
String _$bikesNotifierHash() => r'6335fd9ffa9bf1f77c87798836436257e0f902f9';

/// StateNotifier for managing bikes state and operations
///
/// Copied from [BikesNotifier].
@ProviderFor(BikesNotifier)
final bikesNotifierProvider =
    AutoDisposeNotifierProvider<BikesNotifier, BikesState>.internal(
  BikesNotifier.new,
  name: r'bikesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bikesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BikesNotifier = AutoDisposeNotifier<BikesState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
