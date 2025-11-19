// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bikes_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bikesStreamHash() => r'f3fba82a5e358ad692453c09834498f83443ec1b';

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
String _$offlineBikesHash() => r'ab59280e01afa15cd351100576742cf5176cd575';

/// Provider for offline bikes from Hive
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
String _$bikesNotifierHash() => r'73e5c6216b598960251a3c3c5d5255732abfc61e';

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
