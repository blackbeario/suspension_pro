// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityNotifierHash() =>
    r'ca8e6615ffde8ea3400389ca95ea2d3180102f3d';

/// StateNotifier for managing connectivity state with periodic polling
/// Replaces the ConnectivityBloc singleton pattern
///
/// Copied from [ConnectivityNotifier].
@ProviderFor(ConnectivityNotifier)
final connectivityNotifierProvider =
    AutoDisposeNotifierProvider<ConnectivityNotifier, bool>.internal(
  ConnectivityNotifier.new,
  name: r'connectivityNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectivityNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
