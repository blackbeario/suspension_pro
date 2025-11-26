import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/core/hive_helper/hive_types.dart';
import 'package:ridemetrx/core/hive_helper/hive_adapters.dart';
import 'package:ridemetrx/core/hive_helper/fields/shock_fields.dart';


part 'shock.g.dart';


@HiveType(typeId: HiveTypes.shock, adapterName: HiveAdapters.shock)
class Shock extends HiveObject{
	@HiveField(ShockFields.bikeId)
  final String bikeId;
	@HiveField(ShockFields.year)
  final String year;
	@HiveField(ShockFields.brand)
  final String brand;
	@HiveField(ShockFields.model)
  final String model;
	@HiveField(ShockFields.spacers)
  final String? spacers;
	@HiveField(ShockFields.stroke)
  final String? stroke;
	@HiveField(ShockFields.serialNumber)
  final String? serialNumber;

  Shock({
    required this.bikeId,
    required this.year,
    required this.brand,
    required this.model,
    this.spacers,
    this.stroke,
    this.serialNumber
  });

  factory Shock.fromJson(bikeId, Map<String, dynamic> json) {
    return Shock(
      bikeId: bikeId,
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      spacers: json['spacers'],
      stroke: json['stroke'],
      serialNumber: json['serialNumber'],
    );
  }
}