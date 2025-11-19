import 'package:hive_ce/hive.dart';
import 'package:suspension_pro/core/hive_helper/hive_types.dart';
import 'package:suspension_pro/core/hive_helper/hive_adapters.dart';
import 'package:suspension_pro/core/hive_helper/fields/fork_fields.dart';

part 'fork.g.dart';

@HiveType(typeId: HiveTypes.fork, adapterName: HiveAdapters.fork)
class Fork extends HiveObject{
	@HiveField(ForkFields.bikeId)
  final String bikeId;
	@HiveField(ForkFields.year)
  final String year;
	@HiveField(ForkFields.travel)
  final String? travel;
	@HiveField(ForkFields.damper)
  final String? damper;
	@HiveField(ForkFields.offset)
  final String? offset;
	@HiveField(ForkFields.wheelsize)
  final String? wheelsize;
	@HiveField(ForkFields.brand)
  final String brand;
	@HiveField(ForkFields.model)
  final String model;
	@HiveField(ForkFields.spacers)
  final String? spacers;
	@HiveField(ForkFields.spacing)
  final String? spacing;
	@HiveField(ForkFields.serialNumber)
  final String? serialNumber;

  Fork({
    required this.bikeId,
    required this.year,
    this.travel,
    this.damper,
    this.offset,
    this.wheelsize,
    required this.brand,
    required this.model,
    this.spacers,
    this.spacing,
    this.serialNumber
  });

  factory Fork.fromJson(bikeId, Map<String, dynamic> json) {
    return Fork(
      bikeId: bikeId,
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      travel: json['travel'],
      damper: json['damper'],
      offset: json['offset'],
      wheelsize: json['wheelsize'],
      spacers: json['spacers'],
      spacing: json['spacing'],
      serialNumber: json['serialNumber'],
    );
  }
}