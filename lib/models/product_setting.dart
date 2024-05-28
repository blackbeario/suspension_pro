class ProductSetting {
  // AI might return a variety of keys when parsed as JSON
  // so we try to account for the most common and deal with the failures
  final String? sag, springRate, preload, hsc, lsc, hsr, lsr, compression, rebound, volume_spacers;
  ProductSetting({this.sag, this.springRate, this.preload, this.hsc, this.lsc, this.hsr, this.lsr, this.compression, this.rebound, this.volume_spacers});

  factory ProductSetting.fromJson(Map<String, dynamic> json) {
    return ProductSetting(
      sag: json['sag'] ?? '',
      springRate: json['springRate'] ?? json['spring_rate'] ?? json['air_pressure'] ?? json['pressure'] ?? '',
      preload: json['preload'] ?? '',
      hsc: json['HSC'] ?? json['high_speed_compression'] ?? json["compression"]["high_speed"] ?? '',
      lsc: json['LSC'] ?? json['low_speed_compression'] ?? json["compression"]["low_speed"] ?? '',
      hsr: json['HSR'] ?? json['high_speed_rebound'] ?? json["rebound"]["low_speed"] ?? '',
      lsr: json['LSR'] ?? json['low_speed_rebound'] ?? json["rebound"]["low_speed"] ?? '',
      // compression: json['compression_damping'] ?? _parseValue(json['compression']) ?? '',
      // rebound: json['rebound_damping'] ?? _parseValue(json['rebound']) ?? '',
      volume_spacers: json['volume_spacers'].toString()
    );
  }

  Map<String, dynamic> toJson() => {
    'sag': sag,
    'springRate': springRate,
    'preload': preload,
    'HSC': hsc,
    'LSC': lsc,
    'HSR': hsr,
    'LSR': lsr,
    // compression_damping: json['compression_damping'] ?? '',
    // rebound_damping: json['rebound_damping'] ?? '',
    // volume_spacers: json['volume_spacers'] ?? ''
  };
}

// String? _parseValue(value) {
//   if (value.runtimeType != String) {
//     return null;
//   }
//   return value;
// }