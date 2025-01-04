import 'package:hive/hive.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/models/component.dart';
import 'package:suspension_pro/models/setting.dart';

registerAdapters() async {
	Hive.registerAdapter(BikeAdapter());
	Hive.registerAdapter(ComponentAdapter());
	Hive.registerAdapter(SettingAdapter());
  await Hive.openBox("bikes");
}
