// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conflictCountHash() => r'b991a2168c22c925c8501eb974ba6b3b2a88759c';

/// Provider to get conflict count
///
/// Copied from [conflictCount].
@ProviderFor(conflictCount)
final conflictCountProvider = AutoDisposeProvider<int>.internal(
  conflictCount,
  name: r'conflictCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$conflictCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConflictCountRef = AutoDisposeProviderRef<int>;
String _$conflictNotifierHash() => r'4a4d6e3532adeb5e0d4e9c3197e3c11da7753bfc';

/// Manages data conflicts between local and remote versions
///
/// Copied from [ConflictNotifier].
@ProviderFor(ConflictNotifier)
final conflictNotifierProvider =
    AutoDisposeNotifierProvider<ConflictNotifier, List<DataConflict>>.internal(
  ConflictNotifier.new,
  name: r'conflictNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$conflictNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConflictNotifier = AutoDisposeNotifier<List<DataConflict>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
