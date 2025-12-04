import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/core/hive_helper/hive_types.dart';
import 'package:ridemetrx/core/hive_helper/hive_adapters.dart';
import 'package:ridemetrx/core/hive_helper/fields/setting_fields.dart';
import 'package:ridemetrx/features/bikes/domain/models/component_setting.dart';


part 'setting.g.dart';


@HiveType(typeId: HiveTypes.setting, adapterName: HiveAdapters.setting)
class Setting extends HiveObject{
	@HiveField(SettingFields.id)
  String id;
	@HiveField(SettingFields.bike)
  final String? bike;
	@HiveField(SettingFields.fork)
  final ComponentSetting? fork;
	@HiveField(SettingFields.shock)
  final ComponentSetting? shock;
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
	@HiveField(SettingFields.lastModified)
  final DateTime? lastModified;
	@HiveField(SettingFields.isDirty)
  final bool isDirty;
	@HiveField(SettingFields.isDeleted)
  final bool isDeleted;
	@HiveField(SettingFields.index)
  int? index;

  Setting({
    required this.id,
    this.bike,
    this.fork,
    this.shock,
    this.riderWeight,
    this.updated,
    this.frontTire,
    this.rearTire,
    this.notes,
    this.lastModified,
    this.isDirty = false,
    this.isDeleted = false,
    this.index,
  });

  factory Setting.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Setting(
      id: doc.id,
      riderWeight: data['riderWeight'] ?? '',
      bike: data['bike'] ?? '',
      fork: data['fork'] != null ? ComponentSetting.fromJson(data['fork']) : null,
      shock: data['shock'] != null ? ComponentSetting.fromJson(data['shock']) : null,
      frontTire: data['frontTire'] ?? '',
      rearTire: data['rearTire'] ?? '',
      updated: data['updated'] != null ? DateTime.fromMillisecondsSinceEpoch(data['updated']) : null,
      notes: data['notes'] ?? '',
      lastModified: data['lastModified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastModified'])
          : null,
      isDirty: false, // Data from Firebase is always clean
      isDeleted: data['isDeleted'] ?? false,
      index: data['index'] ?? null,
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
    'riderWeight': riderWeight,
    'lastModified': lastModified?.millisecondsSinceEpoch,
    'isDirty': isDirty,
    'isDeleted': isDeleted,
    'index': index,
  };

  Setting copyWith({
    String? id,
    String? bike,
    ComponentSetting? fork,
    ComponentSetting? shock,
    String? riderWeight,
    DateTime? updated,
    String? frontTire,
    String? rearTire,
    String? notes,
    DateTime? lastModified,
    bool? isDirty,
    bool? isDeleted,
    int? index,
  }) {
    return Setting(
      id: id ?? this.id,
      bike: bike ?? this.bike,
      fork: fork ?? this.fork,
      shock: shock ?? this.shock,
      riderWeight: riderWeight ?? this.riderWeight,
      updated: updated ?? this.updated,
      frontTire: frontTire ?? this.frontTire,
      rearTire: rearTire ?? this.rearTire,
      notes: notes ?? this.notes,
      lastModified: lastModified ?? this.lastModified,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      index: index ?? this.index,
    );
  }
}

String _parseBike(bike) {
  if (bike.runtimeType != String) {
    return bike['make'] + ' ' + bike['model'];
  }
  return bike;
}

ComponentSetting? _parseProduct(Map json, bool isFront) {
  if (isFront) {
    if (json.containsKey('suspension_settings') && json['suspension_settings'].runtimeType != String) {
      Map<String, dynamic> settings = json['suspension_settings'];
      if (settings.containsKey('fork')) {
        return ComponentSetting.fromJson(settings['fork']);
      }
      if (settings.containsKey('front')) {
        return ComponentSetting.fromJson(settings['front']);
      }
      return ComponentSetting.fromJson(settings);
    }
    return null;
  }

  else {
    if (json.containsKey('suspension_settings') && json['suspension_settings'].runtimeType != String) {
      Map<String, dynamic> settings = json['suspension_settings'];
      if (settings.containsKey('shock')) {
        return ComponentSetting.fromJson(settings['shock']);
      }
      if (settings.containsKey('rear')) {
        return ComponentSetting.fromJson(settings['rear']);
      }
      return ComponentSetting.fromJson(settings);
    }
    return null;
  }
}