import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/core/hive_helper/hive_types.dart';
import 'package:ridemetrx/core/hive_helper/hive_adapters.dart';
import 'package:ridemetrx/core/hive_helper/fields/bike_fields.dart';
import 'package:ridemetrx/features/bikes/domain/models/fork.dart';
import 'package:ridemetrx/features/bikes/domain/models/shock.dart';

part 'bike.g.dart';

@HiveType(typeId: HiveTypes.bike, adapterName: HiveAdapters.bike)
class Bike extends HiveObject{
	@HiveField(BikeFields.id)
  final String id;
	@HiveField(BikeFields.yearModel)
  final int? yearModel;
	@HiveField(BikeFields.fork)
  final Fork? fork;
	@HiveField(BikeFields.shock)
  final Shock? shock;
	@HiveField(BikeFields.index)
  int? index;
	@HiveField(BikeFields.bikePic)
  final String? bikePic;
	@HiveField(BikeFields.lastModified)
  final DateTime? lastModified;
	@HiveField(BikeFields.isDirty)
  final bool isDirty;
	@HiveField(BikeFields.isDeleted)
  final bool isDeleted;

  Bike({
    required this.id,
    this.yearModel,
    this.fork,
    this.shock,
    this.index,
    this.bikePic,
    this.lastModified,
    this.isDirty = false,
    this.isDeleted = false,
  });

  factory Bike.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Bike(
      id: doc.id,
      yearModel: data["yearModel"] ?? null,
      fork: Fork.fromJson(doc.id, data["fork"]),
      shock: data["shock"] != null ? Shock.fromJson(doc.id, data["shock"]) : null,
      index: data["index"] ?? null,
      bikePic: data['bikePic'] ?? '',
      lastModified: data['lastModified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastModified'])
          : null,
      isDirty: false, // Data from Firebase is always clean
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<dynamic, dynamic> toJson() => {
        "yearModel": yearModel,
        "fork": fork,
        "shock": shock,
        "index": index,
        'bikePic': bikePic,
        'lastModified': lastModified?.millisecondsSinceEpoch,
        'isDirty': isDirty,
        'isDeleted': isDeleted,
      };

  Bike copyWith({
    String? id,
    int? yearModel,
    Object? fork = const _Undefined(),
    Object? shock = const _Undefined(),
    int? index,
    String? bikePic,
    DateTime? lastModified,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return Bike(
      id: id ?? this.id,
      yearModel: yearModel ?? this.yearModel,
      fork: fork is _Undefined ? this.fork : fork as Fork?,
      shock: shock is _Undefined ? this.shock : shock as Shock?,
      index: index ?? this.index,
      bikePic: bikePic ?? this.bikePic,
      lastModified: lastModified ?? this.lastModified,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

// Helper class to distinguish between "not provided" and "explicitly null"
class _Undefined {
  const _Undefined();
}