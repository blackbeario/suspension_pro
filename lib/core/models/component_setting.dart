import 'package:hive_ce/hive.dart';
import 'package:suspension_pro/core/hive_helper/hive_types.dart';
import 'package:suspension_pro/core/hive_helper/hive_adapters.dart';

part 'component_setting.g.dart';

@HiveType(typeId: HiveTypes.component, adapterName: HiveAdapters.component)
class ComponentSetting extends HiveObject{
  // AI might return a variety of keys when parsed as JSON
  // so we try to account for the most common and deal with the failures
  final String? sag, springRate, preload, hsc, lsc, hsr, lsr, volume_spacers;
  ComponentSetting({this.sag, this.springRate, this.preload, this.hsc, this.lsc, this.hsr, this.lsr, this.volume_spacers});

  factory ComponentSetting.fromJson(Map<String, dynamic> json) {
    return ComponentSetting(
      sag: json['sag'].toString(),
      springRate: json['springRate'] ?? json['spring_rate'].toString() ?? json['air_pressure'] ?? json['pressure'].toString() ?? '',
      preload: json['preload'] ?? json['preload'].toString() ?? '',
      hsc: json['HSC'] ?? json['high_speed_compression'] ?? json["compression"]["high_speed"].toString() ?? '',
      lsc: json['LSC'] ?? json['low_speed_compression'] ?? json["compression"]["low_speed"].toString() ?? '',
      hsr: json['HSR'] ?? json['high_speed_rebound'] ?? json["rebound"]["low_speed"].toString() ?? '',
      lsr: json['LSR'] ?? json['low_speed_rebound'] ?? json["rebound"]["low_speed"].toString() ?? '',
      volume_spacers: json['spacers'].toString()
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