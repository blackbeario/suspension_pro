// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$purchaseNotifierHash() => r'bd50fb5e4baae0282245bc2a8286a878993d8bd2';

/// StateNotifier for managing in-app purchase state
/// Replaces the InAppBloc singleton pattern
///
/// Copied from [PurchaseNotifier].
@ProviderFor(PurchaseNotifier)
final purchaseNotifierProvider =
    AutoDisposeNotifierProvider<PurchaseNotifier, PurchaseState>.internal(
  PurchaseNotifier.new,
  name: r'purchaseNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$purchaseNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PurchaseNotifier = AutoDisposeNotifier<PurchaseState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
