import 'package:hive/hive.dart';

class HiveService {
  void addToBox(String boxName, dynamic object) async {
    try {
      final box = await Hive.box(boxName);
      await box.add(object);
    } catch (e) {
      throw e;
    }
  }

  void putIntoBox(String boxName, String key, dynamic object) async {
    try {
      final box = await Hive.box(boxName);
      await box.put(key, object);
    } catch (e) {
      throw e;
    }
  }

  getAllFromBox(String boxName) async {
    try {
      final box = await Hive.box(boxName);
      return await box.get;
    } catch (e) {
      throw e;
    }
  }

  getFromBox(String boxName, String? key) async {
    try {
      final box = await Hive.box(boxName);
      return await box.get(key);
    } catch (e) {
      throw e;
    }
  }
}
