import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_state.dart';

part 'purchase_notifier.g.dart';

/// Product IDs for RideMetrx Pro subscriptions
const String kProMonthlyId = 'com.ridemetrx.pro.monthly';
const String kProAnnualId = 'com.ridemetrx.pro.annual';
const Set<String> kProProductIds = {kProMonthlyId, kProAnnualId};

/// StateNotifier for managing in-app purchase state (subscriptions)
/// Manages RideMetrx Pro subscription status
@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  @override
  PurchaseState build() {
    // Initialize and check subscription status
    _checkSubscriptionStatus();
    return PurchaseState.initial();
  }

  /// Check current subscription status from past purchases
  Future<void> _checkSubscriptionStatus() async {
    // This will be called by the UI layer to check active subscriptions
    // For now, default to no subscription
    state = state.copyWith(
      subscriptionStatus: SubscriptionStatus.none,
      loading: false,
    );
  }

  /// Save subscription status to SharedPreferences for offline access
  Future<void> _saveSubscriptionToPrefs(SubscriptionStatus status, DateTime? expiryDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_status', status.name);
    if (expiryDate != null) {
      await prefs.setInt('subscription_expiry', expiryDate.millisecondsSinceEpoch);
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

      state = state.copyWith(
        subscriptionStatus: status,
        subscriptionExpiryDate: expiryDate,
      );
    }
  }

  /// Update products list
  void setProducts(List<ProductDetails> products) {
    state = state.copyWith(products: products);
  }

  /// Update purchases list
  void setPurchases(List<PurchaseDetails> purchases) {
    state = state.copyWith(purchases: purchases);
  }

  /// Add a purchase to the list
  void addPurchase(PurchaseDetails purchase) {
    final updatedPurchases = [...state.purchases, purchase];
    state = state.copyWith(purchases: updatedPurchases);
  }

  /// Update loading state
  void setLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }

  /// Update availability
  void setAvailability(bool isAvailable) {
    state = state.copyWith(isAvailable: isAvailable);
  }

  /// Update not found IDs
  void setNotFoundIds(List<String> notFoundIds) {
    state = state.copyWith(notFoundIds: notFoundIds);
  }

  /// Update query product error
  void setQueryProductError(String? error) {
    state = state.copyWith(queryProductError: error);
  }

  /// Update subscription status (called when purchase is verified)
  Future<void> setSubscriptionStatus(SubscriptionStatus status, {DateTime? expiryDate}) async {
    state = state.copyWith(
      subscriptionStatus: status,
      subscriptionExpiryDate: expiryDate,
    );
    await _saveSubscriptionToPrefs(status, expiryDate);
  }

  /// Check if subscription is active (helper method for UI)
  bool get isProSubscriber => state.isPro;

  /// Restore purchases (check for existing subscriptions)
  Future<void> restorePurchases() async {
    // TODO: Implement restore purchases logic with InAppPurchase API
    // This will query past purchases and update subscription status
    await _loadSubscriptionFromPrefs();
  }

  /// Update purchase pending state
  void setPurchasePending(bool pending) {
    state = state.copyWith(purchasePending: pending);
  }
}
