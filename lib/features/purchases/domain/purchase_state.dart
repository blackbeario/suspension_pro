import 'package:in_app_purchase/in_app_purchase.dart';

/// Represents the in-app purchase state
class PurchaseState {
  final List<ProductDetails> products;
  final List<PurchaseDetails> purchases;
  final List<String> consumables;
  final List<String> notFoundIds;
  final bool isAvailable;
  final bool purchasePending;
  final bool loading;
  final String? queryProductError;
  final int credits;

  const PurchaseState({
    this.products = const [],
    this.purchases = const [],
    this.consumables = const [],
    this.notFoundIds = const [],
    this.isAvailable = false,
    this.purchasePending = false,
    this.loading = true,
    this.queryProductError,
    this.credits = 0,
  });

  /// Empty/initial state
  factory PurchaseState.initial() => const PurchaseState();

  /// Copy with method for immutable updates
  PurchaseState copyWith({
    List<ProductDetails>? products,
    List<PurchaseDetails>? purchases,
    List<String>? consumables,
    List<String>? notFoundIds,
    bool? isAvailable,
    bool? purchasePending,
    bool? loading,
    String? queryProductError,
    int? credits,
  }) {
    return PurchaseState(
      products: products ?? this.products,
      purchases: purchases ?? this.purchases,
      consumables: consumables ?? this.consumables,
      notFoundIds: notFoundIds ?? this.notFoundIds,
      isAvailable: isAvailable ?? this.isAvailable,
      purchasePending: purchasePending ?? this.purchasePending,
      loading: loading ?? this.loading,
      queryProductError: queryProductError ?? this.queryProductError,
      credits: credits ?? this.credits,
    );
  }
}
