import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/component_setting.dart';
import 'package:ridemetrx/features/bikes/domain/models/fork.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/features/bikes/domain/models/shock.dart';
import 'package:ridemetrx/features/auth/domain/models/user.dart';
import 'package:ridemetrx/features/sync/domain/models/data_conflict.dart';

registerAdapters() async {
  Hive.registerAdapter(BikeAdapter());
  Hive.registerAdapter(ComponentAdapter());
  Hive.registerAdapter(SettingAdapter());
  Hive.registerAdapter(ForkAdapter());
  Hive.registerAdapter(ShockAdapter());
  Hive.registerAdapter(AppUserAdapter());
  Hive.registerAdapter(DataConflictAdapter());
  await Hive.openBox<Bike>('bikes');
  await Hive.openBox<Setting>('settings');
  await Hive.openBox<AppUser>('hiveUserBox');
  await Hive.openBox<String>('hiveUserPass');
  await Hive.openBox<DataConflict>('conflicts');
}
