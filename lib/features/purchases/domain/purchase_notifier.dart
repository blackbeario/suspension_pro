import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_state.dart';

part 'purchase_notifier.g.dart';

/// Product IDs for RideMetrx Pro subscriptions
/// These are defined in RevenueCat dashboard, not App Store Connect
const String kProMonthlyId = 'pro_monthly';
const String kProAnnualId = 'pro_annual';

/// StateNotifier for managing RevenueCat subscription state
/// Manages RideMetrx Pro subscription status
@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  @override
  PurchaseState build() {
    // Initialize and check subscription status
    _initializeRevenueCat();
    return PurchaseState.initial();
  }

  /// Initialize RevenueCat and check subscription status
  Future<void> _initializeRevenueCat() async {
    try {
      // Check current customer info
      final customerInfo = await Purchases.getCustomerInfo();
      _updateSubscriptionStatus(customerInfo);

      state = state.copyWith(
        loading: false,
        customerInfo: customerInfo,
      );
    } catch (e) {
      print('PurchaseNotifier: Failed to initialize: $e');
      // Load from cache if offline
      await _loadSubscriptionFromPrefs();
      state = state.copyWith(
        loading: false,
        errorMessage: 'Failed to check subscription status',
      );
    }
  }

  /// Fetch available offerings from RevenueCat
  Future<void> fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      state = state.copyWith(offerings: offerings);
    } catch (e) {
      print('PurchaseNotifier: Failed to fetch offerings: $e');
      state = state.copyWith(
        errorMessage: 'Failed to load products',
      );
    }
  }

  /// Purchase a product
  Future<bool> purchaseProduct(Package package) async {
    state = state.copyWith(purchasePending: true, clearError: true);

    try {
      final PurchaseResult purchaseResult = await Purchases.purchase(PurchaseParams.package(package));
      final CustomerInfo customerInfo = purchaseResult.customerInfo;
      _updateSubscriptionStatus(customerInfo); 

      state = state.copyWith(
        purchasePending: false,
        customerInfo: customerInfo,
      );

      return state.isPro;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      String errorMessage;

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        errorMessage = 'Purchase cancelled';
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        errorMessage = 'Purchase not allowed';
      } else {
        errorMessage = 'Purchase failed: ${e.message}';
      }

      print('PurchaseNotifier: Purchase error: $errorMessage');
      state = state.copyWith(
        purchasePending: false,
        errorMessage: errorMessage,
      );

      return false;
    } catch (e) {
      print('PurchaseNotifier: Unexpected error: $e');
      state = state.copyWith(
        purchasePending: false,
        errorMessage: 'An unexpected error occurred',
      );

      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    state = state.copyWith(purchasePending: true, clearError: true);

    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateSubscriptionStatus(customerInfo);

      state = state.copyWith(
        purchasePending: false,
        customerInfo: customerInfo,
      );

      return state.isPro;
    } catch (e) {
      print('PurchaseNotifier: Restore failed: $e');
      state = state.copyWith(
        purchasePending: false,
        errorMessage: 'Failed to restore purchases',
      );

      return false;
    }
  }

  /// Update subscription status from CustomerInfo
  void _updateSubscriptionStatus(CustomerInfo customerInfo) {
    // Check if user has active entitlement for Pro
    final hasPro = customerInfo.entitlements.active.containsKey('pro');

    SubscriptionStatus status;
    DateTime? expiryDate;

    if (hasPro) {
      status = SubscriptionStatus.active;
      final proEntitlement = customerInfo.entitlements.active['pro'];
      expiryDate = proEntitlement?.expirationDate != null
          ? DateTime.parse(proEntitlement!.expirationDate!)
          : null;
    } else {
      // Check if there was a previous subscription
      final hadPro = customerInfo.entitlements.all.containsKey('pro');
      status = hadPro ? SubscriptionStatus.expired : SubscriptionStatus.none;
    }

    state = state.copyWith(
      subscriptionStatus: status,
      subscriptionExpiryDate: expiryDate,
    );

    // Save to SharedPreferences for offline access
    _saveSubscriptionToPrefs(status, expiryDate);
  }

  /// Save subscription status to SharedPreferences for offline access
  Future<void> _saveSubscriptionToPrefs(
    SubscriptionStatus status,
    DateTime? expiryDate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_status', status.name);
    if (expiryDate != null) {
      await prefs.setInt(
        'subscription_expiry',
        expiryDate.millisecondsSinceEpoch,
      );
    }
  }

  /// Load subscription status from SharedPreferences (for offline grace period)
  Future<void> _loadSubscriptionFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('subscription_status');
    final expiryTimestamp = prefs.getInt('subscription_expiry');

    if (statusString != null) {
      final status = SubscriptionStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () => SubscriptionStatus.unknown,
      );
      final expiryDate = expiryTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(expiryTimestamp)
          : null;

      // Check if cached subscription is still valid
      if (expiryDate != null && DateTime.now().isBefore(expiryDate)) {
        state = state.copyWith(
          subscriptionStatus: status,
          subscriptionExpiryDate: expiryDate,
        );
      } else {
        // Expired, set to none
        state = state.copyWith(
          subscriptionStatus: SubscriptionStatus.none,
        );
      }
    }
  }

  /// Check if subscription is active (helper method for UI)
  bool get isProSubscriber => state.isPro;

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
