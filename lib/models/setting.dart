import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suspension_pro/models/product_setting.dart';

class Setting {
  final String id;
  final String? bike;
  final ProductSetting? fork;
  final ProductSetting? shock;
  final int? riderWeight;
  final DateTime? updated;
  final String? frontTire;
  final String? rearTire;
  final String? notes;

  Setting({required this.id, this.bike, this.fork, this.shock, this.riderWeight, this.updated, this.frontTire, this.rearTire, this.notes});

  factory Setting.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Setting(
      id: doc.id,
      riderWeight: data['riderWeight'] ?? 0,
      bike: data['bike'] ?? '',
      fork: data['fork'] != null ? ProductSetting.fromJson(data['fork']) : null,
      shock: data['shock'] != null ? ProductSetting.fromJson(data['shock']) : null,
      frontTire: data['frontTire'] ?? '',
      rearTire: data['rearTire'] ?? '',
      updated: data['updated'] != null ? DateTime.fromMillisecondsSinceEpoch(data['updated']) : null,
      notes: data['notes'] ?? '',
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['settingName'],
      riderWeight: json['riderWeight'] ?? '',
      bike: json['bike'],
      fork: json['fork'] != null ? ProductSetting.fromJson(json['fork']) : null, // Map.from(json['fork'])
      shock: json['shock'] != null ? ProductSetting.fromJson(json['shock']) : null,
      frontTire: json['frontTire'] ?? '',
      rearTire: json['rearTire'] ?? '',
      updated: json['updated'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updated']) : null,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'bike': bike,
    'fork': fork,
    'shock': shock,
    'frontTire': frontTire,
    'rearTire': rearTire,
    'updated': updated?.millisecondsSinceEpoch,
    'notes': notes,
  };
}