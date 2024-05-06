import 'package:cloud_firestore/cloud_firestore.dart';

class Setting {
  final String id;
  final String? bike;
  final Map? fork;
  final Map? shock;
  final DateTime? updated;
  final String? frontTire;
  final String? rearTire;
  final String? notes;

  Setting({required this.id, this.bike, this.fork, this.shock, this.updated, this.frontTire, this.rearTire, this.notes});

  factory Setting.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Setting(
      id: doc.id,
      bike: data['bike'] ?? '',
      fork: data['fork'] != null ? Map.from(data['fork']) : null,
      shock: data['shock'] != null ? Map.from(data['shock']) : null,
      frontTire: data['frontTire'] ?? '',
      rearTire: data['rearTire'] ?? '',
      updated: data['updated'] != null ? DateTime.fromMillisecondsSinceEpoch(data['updated']) : null,
      notes: data['notes'] ?? '',
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
