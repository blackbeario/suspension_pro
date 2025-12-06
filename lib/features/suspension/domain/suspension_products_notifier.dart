import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/suspension/domain/models/suspension_product.dart';
import 'package:ridemetrx/features/suspension/domain/services/suspension_products_service.dart';
import 'package:ridemetrx/features/profile/domain/app_settings_notifier.dart';

part 'suspension_products_notifier.g.dart';

/// Sort options for suspension products
enum SuspensionProductSort {
  yearDesc('Year (Newest First)'),
  yearAsc('Year (Oldest First)'),
  brandAsc('Brand (A-Z)'),
  brandDesc('Brand (Z-A)'),
  modelAsc('Model (A-Z)'),
  modelDesc('Model (Z-A)');

  final String displayName;
  const SuspensionProductSort(this.displayName);
}

/// State for suspension products with loading and error handling
class SuspensionProductsState {
  final List<SuspensionProduct> products;
  final bool isLoading;
  final String? error;
  final SuspensionProductSort sortBy;

  const SuspensionProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.sortBy = SuspensionProductSort.yearDesc,
  });

  SuspensionProductsState copyWith({
    List<SuspensionProduct>? products,
    bool? isLoading,
    String? error,
    SuspensionProductSort? sortBy,
  }) {
    return SuspensionProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Get sorted products based on current sort option
  List<SuspensionProduct> get sortedProducts {
    final sorted = List<SuspensionProduct>.from(products);

    switch (sortBy) {
      case SuspensionProductSort.yearDesc:
        sorted.sort((a, b) {
          final yearCompare = b.year.compareTo(a.year);
          if (yearCompare != 0) return yearCompare;
          return a.brand.compareTo(b.brand); // Secondary sort by brand
        });
      case SuspensionProductSort.yearAsc:
        sorted.sort((a, b) {
          final yearCompare = a.year.compareTo(b.year);
          if (yearCompare != 0) return yearCompare;
          return a.brand.compareTo(b.brand);
        });
      case SuspensionProductSort.brandAsc:
        sorted.sort((a, b) {
          final brandCompare = a.brand.compareTo(b.brand);
          if (brandCompare != 0) return brandCompare;
          return b.year.compareTo(a.year); // Secondary sort by year desc
        });
      case SuspensionProductSort.brandDesc:
        sorted.sort((a, b) {
          final brandCompare = b.brand.compareTo(a.brand);
          if (brandCompare != 0) return brandCompare;
          return b.year.compareTo(a.year);
        });
      case SuspensionProductSort.modelAsc:
        sorted.sort((a, b) {
          final modelCompare = a.model.compareTo(b.model);
          if (modelCompare != 0) return modelCompare;
          return b.year.compareTo(a.year);
        });
      case SuspensionProductSort.modelDesc:
        sorted.sort((a, b) {
          final modelCompare = b.model.compareTo(a.model);
          if (modelCompare != 0) return modelCompare;
          return b.year.compareTo(a.year);
        });
    }

    return sorted;
  }
}

/// Notifier for managing suspension products from local assets
@riverpod
class SuspensionProductsNotifier extends _$SuspensionProductsNotifier {
  late final SuspensionProductsService _service;

  @override
  Future<SuspensionProductsState> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    _service = SuspensionProductsService(prefs);
    return await _loadProducts();
  }

  /// Load products - tries cache first, then local assets, optionally checks for updates
  Future<SuspensionProductsState> _loadProducts() async {
    try {
      // 1. Try loading from cache first (fastest)
      final cachedProducts = await _service.getFromCache();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        // Check for updates in the background (non-blocking)
        _checkForUpdatesInBackground();
        return SuspensionProductsState(products: cachedProducts, isLoading: false);
      }

      // 2. Load from bundled local assets (primary source)
      final products = await _service.loadFromAssets();

      return SuspensionProductsState(products: products, isLoading: false);
    } catch (e) {
      return SuspensionProductsState(
        products: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Check for updates from Firebase in the background (non-blocking)
  Future<void> _checkForUpdatesInBackground() async {
    final shouldCheck = await _service.shouldCheckForUpdates();
    if (!shouldCheck) return;

    try {
      final updatedProducts = await _service.fetchUpdatesFromFirebase();
      if (updatedProducts != null && updatedProducts.isNotEmpty) {
        // Update state with new products
        state = AsyncValue.data(
          SuspensionProductsState(products: updatedProducts, isLoading: false),
        );
      }
    } catch (e) {
      // Fail silently - user still has local version
      print('Background update failed: $e');
    }
  }

  /// Refresh products - forces reload from assets and checks for Firebase updates
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadProducts());
  }

  /// Manually trigger check for updates from Firebase
  Future<void> checkForUpdates() async {
    await _checkForUpdatesInBackground();
  }

  /// Clear cache and force reload from bundled assets
  Future<void> clearCacheAndReload() async {
    await _service.clearCache();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadProducts());
  }

  /// Update sort option
  void setSortOption(SuspensionProductSort sortBy) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(sortBy: sortBy));
  }

  /// Filter products by type (fork or shock) - respects current sort
  List<SuspensionProduct> filterByType(SuspensionType type) {
    final currentState = state.value;
    if (currentState == null) return [];
    return currentState.sortedProducts.where((p) => p.type == type).toList();
  }

  /// Search products by query (brand, model, year) - respects current sort
  List<SuspensionProduct> searchProducts(String query, {SuspensionType? type}) {
    final currentState = state.value;
    if (currentState == null) return [];

    final lowerQuery = query.toLowerCase();
    var products = currentState.sortedProducts;

    // Filter by type if specified
    if (type != null) {
      products = products.where((p) => p.type == type).toList();
    }

    // Search across brand, model, year
    return products.where((product) {
      final searchString = '${product.brand} ${product.model} ${product.year}'
          .toLowerCase();
      return searchString.contains(lowerQuery);
    }).toList();
  }

  /// Filter products by brand - respects current sort
  List<SuspensionProduct> filterByBrand(String brand, {SuspensionType? type}) {
    final currentState = state.value;
    if (currentState == null) return [];

    var products = currentState.sortedProducts
        .where((p) => p.brand.toLowerCase() == brand.toLowerCase());

    if (type != null) {
      products = products.where((p) => p.type == type);
    }

    return products.toList();
  }

  /// Filter products by category - respects current sort
  List<SuspensionProduct> filterByCategory(
    SuspensionCategory category, {
    SuspensionType? type,
  }) {
    final currentState = state.value;
    if (currentState == null) return [];

    var products = currentState.sortedProducts.where((p) => p.category == category);

    if (type != null) {
      products = products.where((p) => p.type == type);
    }

    return products.toList();
  }

  /// Get all unique brands for a suspension type
  List<String> getAvailableBrands({SuspensionType? type}) {
    final currentState = state.value;
    if (currentState == null) return [];

    var products = currentState.products; // Use unsorted for unique list
    if (type != null) {
      products = products.where((p) => p.type == type).toList();
    }

    return products.map((p) => p.brand).toSet().toList()..sort();
  }

  /// Get product by ID
  SuspensionProduct? getProductById(String id) {
    final currentState = state.value;
    if (currentState == null) return null;

    try {
      return currentState.products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all sorted products (convenience method)
  List<SuspensionProduct> getAllProducts() {
    final currentState = state.value;
    if (currentState == null) return [];
    return currentState.sortedProducts;
  }
}
