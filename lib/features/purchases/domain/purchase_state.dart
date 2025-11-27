import 'package:purchases_flutter/purchases_flutter.dart';

/// Subscription status enum
enum SubscriptionStatus {
  none,      // No active subscription
  active,    // Active Pro subscription
  expired,   // Subscription expired
  unknown,   // Status not yet determined
}

/// Represents the in-app purchase state (RevenueCat)
class PurchaseState {
  final bool purchasePending;
  final bool loading;
  final String? errorMessage;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? subscriptionExpiryDate;
  final CustomerInfo? customerInfo;  // RevenueCat customer data
  final Offerings? offerings;        // Available products from RevenueCat

  const PurchaseState({
    this.purchasePending = false,
    this.loading = true,
    this.errorMessage,
    this.subscriptionStatus = SubscriptionStatus.unknown,
    this.subscriptionExpiryDate,
    this.customerInfo,
    this.offerings,
  });

  /// Empty/initial state
  factory PurchaseState.initial() => const PurchaseState();

  /// Helper: Check if user has active Pro subscription
  bool get isPro => subscriptionStatus == SubscriptionStatus.active;

  /// Copy with method for immutable updates
  PurchaseState copyWith({
    bool? purchasePending,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    SubscriptionStatus? subscriptionStatus,
    DateTime? subscriptionExpiryDate,
    CustomerInfo? customerInfo,
    Offerings? offerings,
  }) {
    return PurchaseState(
      purchasePending: purchasePending ?? this.purchasePending,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      customerInfo: customerInfo ?? this.customerInfo,
      offerings: offerings ?? this.offerings,
    );
  }
}
