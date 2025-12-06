import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Type of suspension component
enum SuspensionType {
  fork,
  shock;

  String get displayName {
    switch (this) {
      case SuspensionType.fork:
        return 'Fork';
      case SuspensionType.shock:
        return 'Shock';
    }
  }
}

/// Category/intended use of suspension
enum SuspensionCategory {
  xc,
  trail,
  enduro,
  dh,
  downhill;

  String get displayName {
    switch (this) {
      case SuspensionCategory.xc:
        return 'XC';
      case SuspensionCategory.trail:
        return 'Trail';
      case SuspensionCategory.enduro:
        return 'Enduro';
      case SuspensionCategory.dh:
      case SuspensionCategory.downhill:
        return 'DH';
    }
  }
}

/// Spring type (air or coil)
enum SpringType {
  air,
  coil;

  String get displayName {
    switch (this) {
      case SpringType.air:
        return 'Air';
      case SpringType.coil:
        return 'Coil';
    }
  }
}

/// Suspension product from database
@immutable
class SuspensionProduct {
  final String id;
  final SuspensionType type;
  final String brand;
  final String model;
  final String year;
  final SuspensionCategory category;
  final SuspensionSpecs specs;
  final BaselineSettings? baselineSettings;
  final int? msrp;
  final String? weight;
  final bool discontinued;
  final String? imageUrl;
  final List<String> features;
  final String? manufacturerUrl;
  final String? manualUrl;

  const SuspensionProduct({
    required this.id,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.category,
    required this.specs,
    this.baselineSettings,
    this.msrp,
    this.weight,
    this.discontinued = false,
    this.imageUrl,
    this.features = const [],
    this.manufacturerUrl,
    this.manualUrl,
  });

  /// Display name: "2023 Fox 38 Factory"
  String get displayName => '$year $brand $model';

  /// Short name: "Fox 38"
  String get shortName => '$brand $model';

  /// Category and type: "Enduro Fork"
  String get categoryAndType => '${category.displayName} ${type.displayName}';

  /// Factory method from Firestore document
  factory SuspensionProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SuspensionProduct(
      id: doc.id,
      type: SuspensionType.values.firstWhere(
        (e) => e.name == data['type'],
      ),
      brand: data['brand'] as String,
      model: data['model'] as String,
      year: data['year'] as String,
      category: SuspensionCategory.values.firstWhere(
        (e) => e.name == data['category'],
      ),
      specs: SuspensionSpecs.fromJson(data['specs'] as Map<String, dynamic>),
      baselineSettings: data['baselineSettings'] != null
          ? BaselineSettings.fromJson(
              data['baselineSettings'] as Map<String, dynamic>,
            )
          : null,
      msrp: data['msrp'] as int?,
      weight: data['weight'] as String?,
      discontinued: data['discontinued'] as bool? ?? false,
      imageUrl: data['imageUrl'] as String?,
      features: (data['features'] as List<dynamic>?)?.cast<String>() ?? [],
      manufacturerUrl: data['manufacturerUrl'] as String?,
      manualUrl: data['manualUrl'] as String?,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'brand': brand,
      'model': model,
      'year': year,
      'category': category.name,
      'specs': specs.toJson(),
      'baselineSettings': baselineSettings?.toJson(),
      'msrp': msrp,
      'weight': weight,
      'discontinued': discontinued,
      'imageUrl': imageUrl,
      'features': features,
      'manufacturerUrl': manufacturerUrl,
      'manualUrl': manualUrl,
    };
  }
}

/// Technical specifications for suspension component
@immutable
class SuspensionSpecs {
  // Fork-specific
  final List<String>? travel;
  final List<String>? wheelSizes;
  final String? damperType;
  final String? tubeType;
  final String? axleStandard;

  // Shock-specific
  final String? eyeToEye;
  final String? stroke;
  final String? mountType;

  // Common
  final SpringType springType;

  const SuspensionSpecs({
    this.travel,
    this.wheelSizes,
    this.damperType,
    this.tubeType,
    this.axleStandard,
    this.eyeToEye,
    this.stroke,
    this.mountType,
    required this.springType,
  });

  factory SuspensionSpecs.fromJson(Map<String, dynamic> json) {
    return SuspensionSpecs(
      travel: (json['travel'] as List<dynamic>?)?.cast<String>(),
      wheelSizes: (json['wheelSizes'] as List<dynamic>?)?.cast<String>(),
      damperType: json['damperType'] as String?,
      tubeType: json['tubeType'] as String?,
      axleStandard: json['axleStandard'] as String?,
      eyeToEye: json['eyeToEye'] as String?,
      stroke: json['stroke'] as String?,
      mountType: json['mountType'] as String?,
      springType: SpringType.values.firstWhere(
        (e) => e.name == json['springType'],
        orElse: () => SpringType.air,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travel': travel,
      'wheelSizes': wheelSizes,
      'damperType': damperType,
      'tubeType': tubeType,
      'axleStandard': axleStandard,
      'eyeToEye': eyeToEye,
      'stroke': stroke,
      'mountType': mountType,
      'springType': springType.name,
    };
  }
}

/// Baseline/starting point settings for a suspension product
@immutable
class BaselineSettings {
  final List<AirPressurePoint> airPressureChart;
  final String defaultRebound;
  final CompressionDefaults defaultCompression;
  final String recommendedSag;
  final VolumeSpacerInfo? volumeSpacers;

  const BaselineSettings({
    required this.airPressureChart,
    required this.defaultRebound,
    required this.defaultCompression,
    required this.recommendedSag,
    this.volumeSpacers,
  });

  factory BaselineSettings.fromJson(Map<String, dynamic> json) {
    return BaselineSettings(
      airPressureChart: (json['airPressureChart'] as List<dynamic>)
          .map((e) => AirPressurePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultRebound: json['defaultRebound'] as String,
      defaultCompression: json['defaultCompression'] != null
          ? CompressionDefaults.fromJson(
              json['defaultCompression'] as Map<String, dynamic>,
            )
          : const CompressionDefaults(),
      recommendedSag: json['recommendedSag'] as String,
      volumeSpacers: json['volumeSpacers'] != null
          ? VolumeSpacerInfo.fromJson(
              json['volumeSpacers'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airPressureChart': airPressureChart.map((e) => e.toJson()).toList(),
      'defaultRebound': defaultRebound,
      'defaultCompression': defaultCompression.toJson(),
      'recommendedSag': recommendedSag,
      'volumeSpacers': volumeSpacers?.toJson(),
    };
  }
}

/// Air pressure recommendation for a specific rider weight
@immutable
class AirPressurePoint {
  final String weight; // e.g., "180 lbs"
  final String psi; // e.g., "80-85"

  const AirPressurePoint({
    required this.weight,
    required this.psi,
  });

  factory AirPressurePoint.fromJson(Map<String, dynamic> json) {
    return AirPressurePoint(
      weight: json['weight'] as String,
      psi: json['psi'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'psi': psi,
    };
  }
}

/// Default compression damping settings
@immutable
class CompressionDefaults {
  final String? hsc; // High-speed compression
  final String? lsc; // Low-speed compression

  const CompressionDefaults({
    this.hsc,
    this.lsc,
  });

  factory CompressionDefaults.fromJson(Map<String, dynamic> json) {
    return CompressionDefaults(
      hsc: json['HSC'] as String?,
      lsc: json['LSC'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'HSC': hsc,
      'LSC': lsc,
    };
  }
}

/// Volume spacer information
@immutable
class VolumeSpacerInfo {
  final int recommended;
  final String? note;

  const VolumeSpacerInfo({
    required this.recommended,
    this.note,
  });

  factory VolumeSpacerInfo.fromJson(Map<String, dynamic> json) {
    return VolumeSpacerInfo(
      recommended: json['recommended'] as int,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommended': recommended,
      'note': note,
    };
  }
}
