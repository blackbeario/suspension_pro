import 'package:cloud_firestore/cloud_firestore.dart';

class Bike {
  final String id;
  final int? yearModel;
  final Map? fork;
  final Map? shock;
  int? index;
  final String? bikePic;

  Bike({required this.id, this.yearModel, this.fork, this.shock, this.index, this.bikePic});

  factory Bike.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Bike(
      id: doc.id,
      yearModel: data["yearModel"] ?? null,
      fork: data["fork"] ?? null,
      shock: data["shock"] ?? null,
      index: data["index"] ?? null,
      bikePic: data['bikePic'] ?? '',
    );
  }

  Map<dynamic, dynamic> toJson() => {
        "yearModel": yearModel,
        "fork": fork,
        "shock": shock,
        "index": index,
        'bikePic': bikePic,
      };
}
