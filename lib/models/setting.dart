import 'package:cloud_firestore/cloud_firestore.dart';

class Setting {
  final String id;
  final String bike;
  final Map fork;
  final Map shock;
  final DateTime updated;

  Setting({ this.id, this.bike, this.fork, this.shock, this.updated});

  factory Setting.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return Setting(
      id: doc.documentID,
      bike: data['bike'] ?? '',
      fork: data['fork'] != null ? Map.from(data['fork']) : null,
      shock: data['shock'] != null ? Map.from(data['shock']) : null,
      updated: data['updated'] != null ? DateTime.fromMillisecondsSinceEpoch(data['updated']) : null,
    );
  }

  Map<String, dynamic> toJson() =>
    { 
      'bike' : bike,
      'fork' : fork,
      'shock' : shock,
      'updated' : updated?.millisecondsSinceEpoch,
    };
}