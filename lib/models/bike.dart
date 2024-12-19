import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:suspension_pro/hive_helper/hive_types.dart';
import 'package:suspension_pro/hive_helper/hive_adapters.dart';
import 'package:suspension_pro/hive_helper/fields/bike_fields.dart';

part 'bike.g.dart';

@HiveType(typeId: HiveTypes.bike, adapterName: HiveAdapters.bike)
class Bike extends HiveObject{
	@HiveField(BikeFields.id)
  final String id;
	@HiveField(BikeFields.yearModel)
  final int? yearModel;
	@HiveField(BikeFields.fork)
  final Map? fork;
	@HiveField(BikeFields.shock)
  final Map? shock;
	@HiveField(BikeFields.index)
  int? index;
	@HiveField(BikeFields.bikePic)
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