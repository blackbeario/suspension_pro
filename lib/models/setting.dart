import 'package:cloud_firestore/cloud_firestore.dart';

class Setting {

  final Map fork;
  final Map shock;
  final DateTime updated;

  Setting({ this.fork, this.shock, this.updated});

  factory Setting.fromMap(DocumentSnapshot data) {
    return Setting(
      fork: data['fork'] != null ? Map.from(data['fork']) : null,
      shock: data['shock'] != null ? Map.from(data['shock']) : null,
      updated: data['updated'] != null ? DateTime.fromMillisecondsSinceEpoch(data['updated']) : null,
    );
  }

  Map<String, dynamic> toJson() =>
    {
      'fork' : fork,
      'shock' : shock,
      'updated' : updated?.millisecondsSinceEpoch,
    };
}