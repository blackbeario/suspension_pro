import 'package:hive_ce/hive.dart';

class HiveService {
  void closeBox<T>(String boxName) {
    Hive.box<T>(boxName).close();
  }

  void addToBox<T>(String boxName, T object) {
    try {
      final box = Hive.box<T>(boxName);
      box.add(object);
    } catch (e) {
      throw e;
    }
  }

  void putIntoBox<T>(String boxName, String key, T object, bool overwrite) {
    try {
      final box = Hive.box<T>(boxName);
      // If setting changes are made while offline, the next time the app connects and
      // the firebase_bikes_list is called, the app will check to see if the setting exists and if
      // not, then it will write to Hive. If the setting does exist, nothing will be written.
      // That's good since we don't want new settings overwritten. But we need to make sure the
      // changes are synced to Firebase on reconnect. So I think this works, just need to write
      // workmanager methods to update FB in the background, or manually sync.
      if (!box.containsKey(key) || overwrite) {
        box.put(key, object);
      }
    } catch (e) {
      throw e;
    }
  }

  getAllFromBox<T>(String boxName) {
    try {
      final box = Hive.box<T>(boxName);
      return box.values;
    } catch (e) {
      throw e;
    }
  }

  List<String> getAllKeysFromBox<T>(String boxName) {
    List<String> keysList = [];
    try {
      var boxKeys = Hive.box<T>(boxName).keys;
      for (var key in boxKeys) {
        keysList.add(key.toString());
      }
      return keysList;
    } catch (e) {
      throw e;
    }
  }

  T? getFromBox<T>(String boxName, String? key) {
    try {
      final box = Hive.box<T>(boxName);
      return box.get(key);
    } catch (e) {
      throw e;
    }
  }
}
