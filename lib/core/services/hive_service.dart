import 'package:hive/hive.dart';

class HiveService {
  void closeBox<T>(String boxName) async {
    Hive.box<T>(boxName).close();
  }

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
      // If setting changes are made in the woods offline, the next time the app connects and
      // the firebase_bikes_list is called, the app will check to see if the setting exists and if
      // not, then it will write to Hive. If the setting does exist, nothing will be written.
      // That's good since we don't want new settings overwritten, and if we are reading from Hive
      // only on settings details. But we need to make sure the changes are synced to Firebase
      // on reconnect. So I think this works, just need to write workmanager methods to update FB
      // in the background, or present the user a widget to manually sync updates, etc.
      if (!box.containsKey(key)) {
        await box.put(key, object);
      }
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

  getAllKeysFromBox<T>(String boxName) async {
    List<String> keysList = [];
    try {
      var boxKeys = Hive.box('settings').keys;
      // Iterable<dynamic> keys = box.keys;
      for (var key in boxKeys) {
        keysList.add(key);
      }
      return keysList;
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
