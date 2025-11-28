import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_state.dart';
import 'package:ridemetrx/core/services/db_service.dart';
import 'package:ridemetrx/features/purchases/domain/paywall_display_manager.dart';

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
    // Note: We don't check subscription status here because:
    // 1. RevenueCat is configured in main.dart (must happen before Riverpod)
    // 2. Subscription status is checked in auth_state_listener after Purchases.logIn()
    // This ensures we check status AFTER the user is properly linked to RevenueCat
    return PurchaseState.initial();
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
      print('PurchaseNotifier: Starting purchase for package: ${package.identifier}');
      final PurchaseResult purchaseResult = await Purchases.purchase(PurchaseParams.package(package));
      final CustomerInfo customerInfo = purchaseResult.customerInfo;

      print('PurchaseNotifier: Purchase completed. CustomerInfo received.');
      print('PurchaseNotifier: Original App User ID: ${customerInfo.originalAppUserId}');
      print('PurchaseNotifier: Active entitlements: ${customerInfo.entitlements.active.keys.toList()}');
      print('PurchaseNotifier: All entitlements: ${customerInfo.entitlements.all.keys.toList()}');

      _updateSubscriptionStatus(customerInfo);

      state = state.copyWith(
        purchasePending: false,
        customerInfo: customerInfo,
      );

      print('PurchaseNotifier: isPro after update: ${state.isPro}');
      print('PurchaseNotifier: subscriptionStatus: ${state.subscriptionStatus}');
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
    // Check if user has active entitlement for RideMetrx Pro
    print('PurchaseNotifier: Checking for "RideMetrx Pro" entitlement...');
    final hasPro = customerInfo.entitlements.active.containsKey('RideMetrx Pro');
    print('PurchaseNotifier: Has "RideMetrx Pro" entitlement: $hasPro');

    SubscriptionStatus status;
    DateTime? expiryDate;

    if (hasPro) {
      status = SubscriptionStatus.active;
      final proEntitlement = customerInfo.entitlements.active['RideMetrx Pro'];
      expiryDate = proEntitlement?.expirationDate != null
          ? DateTime.parse(proEntitlement!.expirationDate!)
          : null;
      print('PurchaseNotifier: Pro entitlement active, expiry: $expiryDate');

      // Reset paywall tracking since user is now Pro
      PaywallDisplayManager.resetPaywallTracking();
    } else {
      // Check if there was a previous subscription
      final hadPro = customerInfo.entitlements.all.containsKey('RideMetrx Pro');
      status = hadPro ? SubscriptionStatus.expired : SubscriptionStatus.none;
      print('PurchaseNotifier: No active pro entitlement. Status: $status');
    }

    state = state.copyWith(
      subscriptionStatus: status,
      subscriptionExpiryDate: expiryDate,
    );

    // Save to SharedPreferences for offline access
    _saveSubscriptionToPrefs(status, expiryDate);

    // Sync to Firestore
    _syncSubscriptionToFirestore(hasPro, expiryDate);
  }

  /// Sync subscription status to Firestore
  Future<void> _syncSubscriptionToFirestore(bool isPro, DateTime? expiryDate) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final db = DatabaseService(uid: currentUser.uid);
        await db.updateSubscriptionStatus(isPro, expiryDate);
        print('PurchaseNotifier: Synced subscription to Firestore for user: ${currentUser.uid}');
      }
    } catch (e) {
      print('PurchaseNotifier: Failed to sync subscription to Firestore: $e');
    }
  }

  /// Save subscription status to SharedPreferences for offline access
  /// Uses Firebase UID to make it user-specific
  Future<void> _saveSubscriptionToPrefs(
    SubscriptionStatus status,
    DateTime? expiryDate,
  ) async {
    try {
      // Use Firebase UID directly instead of RevenueCat's originalAppUserId
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('PurchaseNotifier: No Firebase user logged in, skipping prefs save');
        return;
      }

      final userId = currentUser.uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('subscription_status_$userId', status.name);
      if (expiryDate != null) {
        await prefs.setInt(
          'subscription_expiry_$userId',
          expiryDate.millisecondsSinceEpoch,
        );
      }
      print('PurchaseNotifier: Saved subscription to prefs for user: $userId');
    } catch (e) {
      print('PurchaseNotifier: Failed to save subscription to prefs: $e');
    }
  }


  /// Check if subscription is active (helper method for UI)
  bool get isProSubscriber => state.isPro;

  /// Refresh customer info from RevenueCat (e.g., after login)
  Future<void> refreshCustomerInfo() async {
    try {
      print('PurchaseNotifier: Refreshing customer info...');
      final customerInfo = await Purchases.getCustomerInfo();

      // Get Firebase user for comparison
      final firebaseUser = FirebaseAuth.instance.currentUser;
      print('PurchaseNotifier: Firebase UID: ${firebaseUser?.uid ?? "Not logged in"}');
      print('PurchaseNotifier: RevenueCat originalAppUserId: ${customerInfo.originalAppUserId}');
      print('PurchaseNotifier: Note: originalAppUserId may show anonymous ID, but subscription is linked to Firebase UID');

      _updateSubscriptionStatus(customerInfo);

      state = state.copyWith(
        customerInfo: customerInfo,
      );
      print('PurchaseNotifier: Customer info refreshed. isPro: ${state.isPro}');
    } catch (e) {
      print('PurchaseNotifier: Failed to refresh customer info: $e');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
