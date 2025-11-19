import 'package:hive_ce/hive.dart';
import 'package:suspension_pro/features/bikes/domain/models/bike.dart';
import 'package:suspension_pro/features/bikes/domain/models/component_setting.dart';
import 'package:suspension_pro/features/bikes/domain/models/fork.dart';
import 'package:suspension_pro/features/bikes/domain/models/setting.dart';
import 'package:suspension_pro/features/bikes/domain/models/shock.dart';
import 'package:suspension_pro/features/auth/domain/models/user.dart';

registerAdapters() async {
  Hive.registerAdapter(BikeAdapter());
  Hive.registerAdapter(ComponentAdapter());
  Hive.registerAdapter(SettingAdapter());
  Hive.registerAdapter(ForkAdapter());
  Hive.registerAdapter(ShockAdapter());
  Hive.registerAdapter(AppUserAdapter());
  await Hive.openBox<Bike>('bikes');
  await Hive.openBox<Setting>('settings');
  await Hive.openBox<AppUser>('hiveUserBox');
  await Hive.openBox<String>('hiveUserPass');
}
