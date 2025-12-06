import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridemetrx/features/suspension/domain/models/suspension_product.dart';

/// Service for managing suspension products from local assets and Firebase
class SuspensionProductsService {
  static const String _localAssetPath = 'assets/data/suspension_products.json';
  static const String _lastUpdateKey = 'suspension_products_last_update';
  static const String _versionKey = 'suspension_products_version';
  static const String _cachedProductsKey = 'suspension_products_cache';

  final SharedPreferences _prefs;

  SuspensionProductsService(this._prefs);

  /// Load products from local bundled assets (primary source)
  Future<List<SuspensionProduct>> loadFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(_localAssetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((json) => _productFromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load suspension products from assets: $e');
    }
  }

  /// Get the current version of the local product database
  Future<String> getLocalVersion() async {
    return _prefs.getString(_versionKey) ?? '1.0.0';
  }

  /// Get the last time products were updated from Firebase
  Future<DateTime?> getLastUpdateTime() async {
    final timestamp = _prefs.getInt(_lastUpdateKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if we should fetch updates from Firebase
  /// (e.g., once per week for non-critical updates)
  Future<bool> shouldCheckForUpdates() async {
    final lastUpdate = await getLastUpdateTime();
    if (lastUpdate == null) return true; // Never updated

    final daysSinceUpdate = DateTime.now().difference(lastUpdate).inDays;
    return daysSinceUpdate >= 7; // Check weekly
  }

  /// Fetch updated products from Firebase (optional background update)
  /// This is for adding new products without requiring an app update
  Future<List<SuspensionProduct>?> fetchUpdatesFromFirebase() async {
    try {
      // Check if there's a newer version available
      final remoteVersionDoc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('suspension_products_version')
          .get();

      if (!remoteVersionDoc.exists) {
        return null; // No remote version configured yet
      }

      final remoteVersion = remoteVersionDoc.data()?['version'] as String?;
      final localVersion = await getLocalVersion();

      // If remote version is same or older, no update needed
      if (remoteVersion == null || remoteVersion == localVersion) {
        await _updateLastCheckedTime();
        return null;
      }

      // Fetch updated products from Firebase
      final snapshot = await FirebaseFirestore.instance
          .collection('suspension_products')
          .where('discontinued', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final products = snapshot.docs
          .map((doc) => SuspensionProduct.fromFirestore(doc))
          .toList();

      // Cache the updated products
      await _cacheProducts(products, remoteVersion);
      await _updateLastCheckedTime();

      return products;
    } catch (e) {
      print('Failed to fetch updates from Firebase: $e');
      return null; // Fail gracefully, keep using local version
    }
  }

  /// Get products from cache if available and fresh
  Future<List<SuspensionProduct>?> getFromCache() async {
    final cachedJson = _prefs.getString(_cachedProductsKey);
    if (cachedJson == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(cachedJson);
      return jsonList.map((json) => _productFromJson(json)).toList();
    } catch (e) {
      print('Failed to parse cached products: $e');
      return null;
    }
  }

  /// Cache products to local storage
  Future<void> _cacheProducts(List<SuspensionProduct> products, String version) async {
    final jsonList = products.map((p) => p.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await _prefs.setString(_cachedProductsKey, jsonString);
    await _prefs.setString(_versionKey, version);
  }

  /// Update the last checked timestamp
  Future<void> _updateLastCheckedTime() async {
    await _prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear cached products (useful for debugging or forcing reload)
  Future<void> clearCache() async {
    await _prefs.remove(_cachedProductsKey);
    await _prefs.remove(_lastUpdateKey);
  }

  /// Convert JSON map to SuspensionProduct
  /// (Similar to fromFirestore but for local JSON)
  SuspensionProduct _productFromJson(Map<String, dynamic> json) {
    return SuspensionProduct(
      id: json['id'] ?? _generateId(json),
      type: SuspensionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as String,
      category: SuspensionCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      specs: SuspensionSpecs.fromJson(json['specs'] as Map<String, dynamic>),
      baselineSettings: json['baselineSettings'] != null
          ? BaselineSettings.fromJson(
              json['baselineSettings'] as Map<String, dynamic>,
            )
          : null,
      msrp: json['msrp'] as int?,
      weight: json['weight'] as String?,
      discontinued: json['discontinued'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      manufacturerUrl: json['manufacturerUrl'] as String?,
      manualUrl: json['manualUrl'] as String?,
    );
  }

  /// Generate a consistent ID for products without one
  String _generateId(Map<String, dynamic> json) {
    return '${json['brand']}_${json['model']}_${json['year']}'
        .toLowerCase()
        .replaceAll(' ', '_');
  }
}
