import 'package:flutter/foundation.dart';

/// Category of mountain bike based on intended use
enum BikeCategory {
  xc,
  trail,
  enduro,
  dh;

  String get displayName {
    switch (this) {
      case BikeCategory.xc:
        return 'XC';
      case BikeCategory.trail:
        return 'Trail';
      case BikeCategory.enduro:
        return 'Enduro';
      case BikeCategory.dh:
        return 'Downhill';
    }
  }
}

/// Represents a mountain bike product from the database
/// Used for bike picker and product matching
@immutable
class BikeProduct {
  final String id; // Generated: brand_model_year (e.g., "santa_cruz_nomad_2023")
  final String brand; // "Santa Cruz"
  final String model; // "Nomad"
  final String year; // "2023"
  final BikeCategory category; // xc, trail, enduro, dh
  final String? wheelSize; // "29\"" or "27.5\"" or "MX" (mullet)
  final String? imageUrl; // Optional product image URL
  final bool discontinued; // Is this model still in production?
  final int? msrp; // Manufacturer's suggested retail price in USD

  const BikeProduct({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.category,
    this.wheelSize,
    this.imageUrl,
    this.discontinued = false,
    this.msrp,
  });

  factory BikeProduct.fromJson(Map<String, dynamic> json) {
    return BikeProduct(
      id: json['id'] as String,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'category': category.name,
      'wheelSize': wheelSize,
      'imageUrl': imageUrl,
      'discontinued': discontinued,
      'msrp': msrp,
    };
  }

  /// Display name for the bike
  String get displayName => '$brand $model ($year)';

  /// Short name without year
  String get shortName => '$brand $model';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BikeProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
