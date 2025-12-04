import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/core/hive_helper/hive_types.dart';
import 'package:ridemetrx/core/hive_helper/hive_adapters.dart';

part 'component_setting.g.dart';

@HiveType(typeId: HiveTypes.component, adapterName: HiveAdapters.component)
class ComponentSetting {

  @HiveField(0)
  final String? sag;
  @HiveField(1)
  final String? springRate;
  @HiveField(2)
  final String? preload;
  @HiveField(3)
  final String? hsc;
  @HiveField(4)
  final String? lsc;
  @HiveField(5)
  final String? hsr;
  @HiveField(6)
  final String? lsr;
  @HiveField(7)
  final String? volume_spacers;

  ComponentSetting({this.sag, this.springRate, this.preload, this.hsc, this.lsc, this.hsr, this.lsr, this.volume_spacers});

  factory ComponentSetting.fromJson(Map<String, dynamic> json) {
    return ComponentSetting(
      sag: json['sag']?.toString(),
      springRate: json['springRate']?.toString(),
      preload: json['preload']?.toString(),
      hsc: json['HSC']?.toString(),
      lsc: json['LSC']?.toString(),
      hsr: json['HSR']?.toString(),
      lsr: json['LSR']?.toString(),
      volume_spacers: json['spacers']?.toString()
    );
  }

  Map<String, dynamic> toJson() => {
    'sag': sag,
    'springRate': springRate,
    'preload': preload,
    'HSC': hsc,
    'LSC': lsc,
    'HSR': hsr,
    'LSR': lsr,
    'spacers': volume_spacers,
  };
}