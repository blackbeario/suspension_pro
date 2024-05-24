class ProductSetting {
  final String? sag, springRate, hsc, lsc, hsr, lsr;
  ProductSetting({this.sag, this.springRate, this.hsc, this.lsc, this.hsr, this.lsr});

  factory ProductSetting.fromJson(Map<String, dynamic> json) {
    return ProductSetting(
      sag: json['sag'] ?? '',
      springRate: json['springRate'] ?? '',
      hsc: json['HSC'] ?? '',
      lsc: json['LSC'] ?? '',
      hsr: json['HSR'] ?? '',
      lsr: json['LSR'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'sag': sag,
    'springRate': springRate,
    'HSC': hsc,
    'LSC': lsc,
    'HSR': hsr,
    'LSR': lsr,
  };
}