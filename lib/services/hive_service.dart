import 'package:hive/hive.dart';

class HiveService {
  void addToBox<T>(String boxName, T object) async {
    try {
      final box = await Hive.box<T>(boxName);
      await box.add(object);
    } catch (e) {
      throw e;
    }
  }

  void putIntoBox<T>(String boxName, String key, T object) async {
    try {
      final box = await Hive.box<T>(boxName);
      await box.put(key, object);
    } catch (e) {
      throw e;
    }
  }

  getAllFromBox<T>(String boxName) async {
    try {
      final box = await Hive.box<T>(boxName);
      return await box.get;
    } catch (e) {
      throw e;
    }
  }

  getFromBox<T>(String boxName, String? key) async {
    try {
      final box = await Hive.box<T>(boxName);
      return await box.get(key);
    } catch (e) {
      throw e;
    }
  }
}
