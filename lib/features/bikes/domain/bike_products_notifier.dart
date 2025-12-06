import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike_product.dart';
import 'package:ridemetrx/features/bikes/domain/services/bike_products_service.dart';
import 'package:ridemetrx/features/profile/domain/app_settings_notifier.dart';

part 'bike_products_notifier.g.dart';

/// Sort options for bike products
enum BikeProductSort {
  yearDesc('Year (Newest First)'),
  yearAsc('Year (Oldest First)'),
  brandAsc('Brand (A-Z)'),
  brandDesc('Brand (Z-A)'),
  modelAsc('Model (A-Z)'),
  modelDesc('Model (Z-A)');

  final String displayName;
  const BikeProductSort(this.displayName);
}

/// State for bike products with loading and error handling
class BikeProductsState {
  final List<BikeProduct> products;
  final bool isLoading;
  final String? error;
  final BikeProductSort sortBy;

  const BikeProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.sortBy = BikeProductSort.yearDesc,
  });

  BikeProductsState copyWith({
    List<BikeProduct>? products,
    bool? isLoading,
    String? error,
    BikeProductSort? sortBy,
  }) {
    return BikeProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Get sorted products based on current sort option
  List<BikeProduct> get sortedProducts {
    final sorted = List<BikeProduct>.from(products);

    switch (sortBy) {
      case BikeProductSort.yearDesc:
        sorted.sort((a, b) {
          final yearCompare = b.year.compareTo(a.year);
          if (yearCompare != 0) return yearCompare;
          return a.brand.compareTo(b.brand); // Secondary sort by brand
        });
      case BikeProductSort.yearAsc:
        sorted.sort((a, b) {
          final yearCompare = a.year.compareTo(b.year);
          if (yearCompare != 0) return yearCompare;
          return a.brand.compareTo(b.brand);
        });
      case BikeProductSort.brandAsc:
        sorted.sort((a, b) {
          final brandCompare = a.brand.compareTo(b.brand);
          if (brandCompare != 0) return brandCompare;
          return b.year.compareTo(a.year); // Secondary sort by year desc
        });
      case BikeProductSort.brandDesc:
        sorted.sort((a, b) {
          final brandCompare = b.brand.compareTo(a.brand);
          if (brandCompare != 0) return brandCompare;
          return b.year.compareTo(a.year);
        });
      case BikeProductSort.modelAsc:
        sorted.sort((a, b) {
          final modelCompare = a.model.compareTo(b.model);
          if (modelCompare != 0) return modelCompare;
          return b.year.compareTo(a.year);
        });
      case BikeProductSort.modelDesc:
        sorted.sort((a, b) {
          final modelCompare = b.model.compareTo(a.model);
          if (modelCompare != 0) return modelCompare;
          return b.year.compareTo(a.year);
        });
    }

    return sorted;
  }
}

/// Notifier for managing bike products from local assets
@riverpod
class BikeProductsNotifier extends _$BikeProductsNotifier {
  late final BikeProductsService _service;

  @override
  Future<BikeProductsState> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    _service = BikeProductsService(prefs);
    return await _loadProducts();
  }

  /// Load products - tries cache first, then local assets
  Future<BikeProductsState> _loadProducts() async {
    try {
      // 1. Try loading from cache first (fastest)
      final cachedProducts = await _service.getFromCache();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        return BikeProductsState(products: cachedProducts, isLoading: false);
      }

      // 2. Load from bundled local assets
      final products = await _service.loadFromAssets();

      return BikeProductsState(products: products, isLoading: false);
    } catch (e) {
      return BikeProductsState(
        products: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh products - forces reload from assets
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadProducts());
  }

  /// Clear cache and force reload from bundled assets
  Future<void> clearCacheAndReload() async {
    await _service.clearCache();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadProducts());
  }

  /// Update sort option
  void setSortOption(BikeProductSort sortBy) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(sortBy: sortBy));
  }

  /// Filter products by category - respects current sort
  List<BikeProduct> filterByCategory(BikeCategory category) {
    final currentState = state.value;
    if (currentState == null) return [];
    return currentState.sortedProducts.where((p) => p.category == category).toList();
  }

  /// Search products by query (brand, model, year) - respects current sort
  List<BikeProduct> searchProducts(String query, {BikeCategory? category}) {
    final currentState = state.value;
    if (currentState == null) return [];

    final lowerQuery = query.toLowerCase();
    var products = currentState.sortedProducts;

    // Filter by category if specified
    if (category != null) {
      products = products.where((p) => p.category == category).toList();
    }

    // Search across brand, model, year
    return products.where((product) {
      final searchString = '${product.brand} ${product.model} ${product.year}'
          .toLowerCase();
      return searchString.contains(lowerQuery);
    }).toList();
  }

  /// Filter products by brand - respects current sort
  List<BikeProduct> filterByBrand(String brand, {BikeCategory? category}) {
    final currentState = state.value;
    if (currentState == null) return [];

    var products = currentState.sortedProducts
        .where((p) => p.brand.toLowerCase() == brand.toLowerCase());

    if (category != null) {
      products = products.where((p) => p.category == category);
    }

    return products.toList();
  }

  /// Get all unique brands
  List<String> getAvailableBrands({BikeCategory? category}) {
    final currentState = state.value;
    if (currentState == null) return [];

    var products = currentState.products; // Use unsorted for unique list
    if (category != null) {
      products = products.where((p) => p.category == category).toList();
    }

    return products.map((p) => p.brand).toSet().toList()..sort();
  }

  /// Get product by ID
  BikeProduct? getProductById(String id) {
    final currentState = state.value;
    if (currentState == null) return null;

    try {
      return currentState.products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all sorted products (convenience method)
  List<BikeProduct> getAllProducts() {
    final currentState = state.value;
    if (currentState == null) return [];
    return currentState.sortedProducts;
  }
}
