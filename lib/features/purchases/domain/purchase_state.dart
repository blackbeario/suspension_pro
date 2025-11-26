import 'package:in_app_purchase/in_app_purchase.dart';

/// Subscription status enum
enum SubscriptionStatus {
  none,      // No active subscription
  active,    // Active Pro subscription
  expired,   // Subscription expired
  unknown,   // Status not yet determined
}

/// Represents the in-app purchase state
class PurchaseState {
  final List<ProductDetails> products;
  final List<PurchaseDetails> purchases;
  final List<String> notFoundIds;
  final bool isAvailable;
  final bool purchasePending;
  final bool loading;
  final String? queryProductError;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? subscriptionExpiryDate;

  const PurchaseState({
    this.products = const [],
    this.purchases = const [],
    this.notFoundIds = const [],
    this.isAvailable = false,
    this.purchasePending = false,
    this.loading = true,
    this.queryProductError,
    this.subscriptionStatus = SubscriptionStatus.unknown,
    this.subscriptionExpiryDate,
  });

  /// Empty/initial state
  factory PurchaseState.initial() => const PurchaseState();

  /// Helper: Check if user has active Pro subscription
  bool get isPro => subscriptionStatus == SubscriptionStatus.active;

  /// Copy with method for immutable updates
  PurchaseState copyWith({
    List<ProductDetails>? products,
    List<PurchaseDetails>? purchases,
    List<String>? notFoundIds,
    bool? isAvailable,
    bool? purchasePending,
    bool? loading,
    String? queryProductError,
    SubscriptionStatus? subscriptionStatus,
    DateTime? subscriptionExpiryDate,
  }) {
    return PurchaseState(
      products: products ?? this.products,
      purchases: purchases ?? this.purchases,
      notFoundIds: notFoundIds ?? this.notFoundIds,
      isAvailable: isAvailable ?? this.isAvailable,
      purchasePending: purchasePending ?? this.purchasePending,
      loading: loading ?? this.loading,
      queryProductError: queryProductError ?? this.queryProductError,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
    );
  }
}
