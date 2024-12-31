import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suspension_pro/models/component.dart';

class Setting {
  final String id;
  final String? bike;
  final Component? fork;
  final Component? shock;
  final String? riderWeight;
  final DateTime? updated;
  final String? frontTire;
  final String? rearTire;
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
    // else if (json.containsKey('settings') && json['settings'].runtimeType != String) {
    //   Map<String, dynamic> settings = json['settings'];
    //   if (settings.containsKey('front')) {
    //     return Component.fromJson(settings['front']);
    //   }
    //   return Component.fromJson(settings);
    // }
    // else if (json.containsKey('suspension') && json['suspension'].runtimeType != String) {
    //   Map<String, dynamic> settings = json['suspension'];
    //   if (settings.containsKey('front')) {
    //     return Component.fromJson(settings['front']);
    //   }
    //   return Component.fromJson(settings);
    // }
    // else if (json.containsKey('components') && json['components'].runtimeType != String) {
    //   Map<String, dynamic> settings = json['components'];
    //   if (settings.containsKey('fork')) {
    //     return Component.fromJson(settings['fork']['settings']);
    //   }
    //   if (settings.containsKey('front')) {
    //     return Component.fromJson(settings['front']);
    //   }
    //   return Component.fromJson(settings);
    // }
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
    // else if (json.containsKey('settings') && json['settings'].runtimeType != String) {
    //   Map<String, dynamic> settings = json['settings'];
    //   if (settings.containsKey('rear')) {
    //     return Component.fromJson(settings['rear']);
    //   }
    //   return Component.fromJson(settings);
    // }
    // else if (json.containsKey('suspension') && json['suspension'].runtimeType != String) {
    //   Map<String, dynamic> settings = json['suspension'];
    //   if (settings.containsKey('rear')) {
    //     return Component.fromJson(settings['rear']);
    //   }
    //   return Component.fromJson(settings);
    // }
    // else if (json.containsKey('components') && json['components'].runtimeType != String) {
    //   Map<String, dynamic> settings = json['components'];
    //   if (settings.containsKey('shock')) {
    //     return Component.fromJson(settings['shock']['settings']);
    //   }
    //   if (settings.containsKey('rear')) {
    //     return Component.fromJson(settings['rear']);
    //   }
    //   return Component.fromJson(settings);
    // }
    return null;
  }
}