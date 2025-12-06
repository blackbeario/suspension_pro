import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike_product.dart';

/// Service for managing bike products from local assets
/// Currently local-only, can be extended for Firebase sync later
class BikeProductsService {
  static const String _localAssetPath = 'assets/data/bike_products.json';
  static const String _cachedProductsKey = 'bike_products_cache';
  static const String _lastLoadKey = 'bike_products_last_load';

  final SharedPreferences _prefs;

  BikeProductsService(this._prefs);

  /// Load bike products from local bundled assets
  Future<List<BikeProduct>> loadFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(_localAssetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);

      final products = jsonList.map((json) => _productFromJson(json)).toList();

      // Cache for faster subsequent loads
      await _cacheProducts(products);

      return products;
    } catch (e) {
      throw Exception('Failed to load bike products from assets: $e');
    }
  }

  /// Get products from cache if available
  Future<List<BikeProduct>?> getFromCache() async {
    final cachedJson = _prefs.getString(_cachedProductsKey);
    if (cachedJson == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(cachedJson);
      return jsonList.map((json) => _productFromJson(json)).toList();
    } catch (e) {
      print('Failed to parse cached bike products: $e');
      return null;
    }
  }

  /// Cache products to local storage for faster loads
  Future<void> _cacheProducts(List<BikeProduct> products) async {
    final jsonList = products.map((p) => p.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await _prefs.setString(_cachedProductsKey, jsonString);
    await _prefs.setInt(_lastLoadKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear cached products (useful for forcing reload)
  Future<void> clearCache() async {
    await _prefs.remove(_cachedProductsKey);
    await _prefs.remove(_lastLoadKey);
  }

  /// Convert JSON map to BikeProduct
  BikeProduct _productFromJson(Map<String, dynamic> json) {
    return BikeProduct(
      id: _generateId(json),
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as String,
      category: BikeCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      wheelSize: json['wheelSize'] as String?,
      imageUrl: json['imageUrl'] as String?,
      discontinued: json['discontinued'] as bool? ?? false,
      msrp: json['msrp'] as int?,
    );
  }

  /// Generate a consistent ID for bike products
  /// Format: brand_model_year (e.g., "santa_cruz_nomad_2023")
  String _generateId(Map<String, dynamic> json) {
    final brand = (json['brand'] as String).toLowerCase().replaceAll(' ', '_');
    final model = (json['model'] as String).toLowerCase().replaceAll(' ', '_');
    final year = json['year'] as String;
    return '${brand}_${model}_$year';
  }
}
