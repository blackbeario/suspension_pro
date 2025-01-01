import 'package:hive/hive.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/models/component_setting.dart';
import 'package:suspension_pro/models/setting.dart';
import 'package:suspension_pro/models/fork.dart';
import 'package:suspension_pro/models/shock.dart';

void registerAdapters() {
	Hive.registerAdapter(BikeAdapter());
	Hive.registerAdapter(ComponentSettingAdapter());
	Hive.registerAdapter(SettingAdapter());
	Hive.registerAdapter(ForkAdapter());
	Hive.registerAdapter(ShockAdapter());
}
