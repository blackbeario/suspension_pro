// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$purchaseNotifierHash() => r'dca44a1ded9e1ddecaf0334b3c0c1422ac6316e3';

/// StateNotifier for managing in-app purchase state (subscriptions)
/// Manages RideMetrx Pro subscription status
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
