import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:suspension_pro/hive_helper/hive_types.dart';
import 'package:suspension_pro/hive_helper/hive_adapters.dart';
import 'package:suspension_pro/hive_helper/fields/setting_fields.dart';
import 'package:suspension_pro/models/component.dart';


part 'setting.g.dart';


@HiveType(typeId: HiveTypes.setting, adapterName: HiveAdapters.setting)
class Setting extends HiveObject{
	@HiveField(SettingFields.id)
  final String id;
	@HiveField(SettingFields.bike)
  final String? bike;
	@HiveField(SettingFields.fork)
  final Component? fork;
	@HiveField(SettingFields.shock)
  final Component? shock;
	@HiveField(SettingFields.riderWeight)
  final String? riderWeight;
	@HiveField(SettingFields.updated)
  final DateTime? updated;
	@HiveField(SettingFields.frontTire)
  final String? frontTire;
	@HiveField(SettingFields.rearTire)
  final String? rearTire;
	@HiveField(SettingFields.notes)
  final String? notes;

  Setting({required this.id, this.bike, this.fork, this.shock, this.riderWeight, this.updated, this.frontTire, this.rearTire, this.notes});

  factory Setting.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Setting(
      id: doc.id,
      riderWeight: data['riderWeight'] ?? '',
      bike: data['bike'] ?? '',
      fork: data['fork'] != null ? Component.fromJson(data['fork']) : null,
      shock: data['shock'] != null ? Component.fromJson(data['shock']) : null,
      frontTire: data['frontTire'] ?? '',
      rearTire: data['rearTire'] ?? '',
      updated: data['updated'] != null ? DateTime.fromMillisecondsSinceEpoch(data['updated']) : null,
      notes: data['notes'] ?? '',
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['settingName'] ?? '',
      riderWeight: json['riderWeight'] ?? '',
      bike: _parseBike(json['bike']),
      fork: _parseProduct(json, true),
      shock: _parseProduct(json, false),
      frontTire: json['front_tire_pressure'].toString(),
      rearTire: json['rear_tire_pressure'].toString(),
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

String _parseBike(bike) {
  if (bike.runtimeType != String) {
    return bike['make'] + ' ' + bike['model'];
  }
  return bike;
}

Component? _parseProduct(Map json, bool isFront) {
  if (isFront) {
    if (json.containsKey('suspension_settings') && json['suspension_settings'].runtimeType != String) {
      Map<String, dynamic> settings = json['suspension_settings'];
      if (settings.containsKey('fork')) {
        return Component.fromJson(settings['fork']);
      }
      if (settings.containsKey('front')) {
        return Component.fromJson(settings['front']);
      }
      return Component.fromJson(settings);
    }
    return null;
  }

  else {
    if (json.containsKey('suspension_settings') && json['suspension_settings'].runtimeType != String) {
      Map<String, dynamic> settings = json['suspension_settings'];
      if (settings.containsKey('shock')) {
        return Component.fromJson(settings['shock']);
      }
      if (settings.containsKey('rear')) {
        return Component.fromJson(settings['rear']);
      }
      return Component.fromJson(settings);
    }
    return null;
  }
}