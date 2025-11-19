import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suspension_pro/features/purchases/domain/purchase_state.dart';

part 'purchase_notifier.g.dart';

/// StateNotifier for managing in-app purchase state
/// Replaces the InAppBloc singleton pattern
@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  @override
  PurchaseState build() {
    // Initialize with empty state
    _loadCreditsFromPrefs();
    return PurchaseState.initial();
  }

  /// Load credits from SharedPreferences on initialization
  Future<void> _loadCreditsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final credits = prefs.getInt('credits') ?? 0;
    state = state.copyWith(credits: credits);
  }

  /// Save credits to SharedPreferences
  Future<void> _saveCreditsToPrefs(int credits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('credits', credits);
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

  /// Update consumables
  void setConsumables(List<String> consumables) {
    state = state.copyWith(consumables: consumables);
  }

  /// Update query product error
  void setQueryProductError(String? error) {
    state = state.copyWith(queryProductError: error);
  }

  /// Set AI credits
  Future<void> setCredits(int credits) async {
    state = state.copyWith(credits: credits);
    await _saveCreditsToPrefs(credits);
  }

  /// Remove one credit (decrement)
  Future<void> removeCredit() async {
    if (state.credits > 0) {
      final newCredits = state.credits - 1;
      state = state.copyWith(credits: newCredits);
      await _saveCreditsToPrefs(newCredits);
    }
  }

  /// Update purchase pending state
  void setPurchasePending(bool pending) {
    state = state.copyWith(purchasePending: pending);
  }
}
