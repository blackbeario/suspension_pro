import 'package:cloud_firestore/cloud_firestore.dart';

class Bike {
  final String? id;
  final Map? fork;
  final Map? shock;
  int? index;
  final String? bikePic;

  Bike({this.id, this.fork, this.shock, this.index, this.bikePic});

  factory Bike.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Bike(
      id: doc.id,
      fork: data["fork"] ?? null,
      shock: data["shock"] ?? null,
      index: data["index"] ?? null,
      bikePic: data['bikePic'] ?? '',
    );
  }

  Map<dynamic, dynamic> toJson() => {
        "fork": fork,
        "shock": shock,
        "index": index,
        'bikePic': bikePic,
      };
}
