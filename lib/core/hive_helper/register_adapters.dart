import 'package:hive/hive.dart';
import 'package:suspension_pro/core/models/bike.dart';
import 'package:suspension_pro/core/models/component_setting.dart';
import 'package:suspension_pro/core/models/fork.dart';
import 'package:suspension_pro/core/models/setting.dart';
import 'package:suspension_pro/core/models/shock.dart';
import 'package:suspension_pro/core/models/user.dart';

registerAdapters() async {
  Hive.registerAdapter(BikeAdapter());
  Hive.registerAdapter(ComponentSettingAdapter());
  Hive.registerAdapter(SettingAdapter());
  Hive.registerAdapter(ForkAdapter());
  Hive.registerAdapter(ShockAdapter());
  Hive.registerAdapter(AppUserAdapter());
  await Hive.openBox<Bike>('bikes');
  await Hive.openBox<AppUser>('hiveUserBox');
  await Hive.openBox<String>('hiveUserPass');
}
