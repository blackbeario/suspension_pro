import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/core/services/hive_service.dart';
import 'package:hive_ce/hive.dart';

part 'settings_notifier.g.dart';

/// Stream provider for settings from Firestore for a specific bike
@riverpod
Stream<List<Setting>> settingsStream(Ref ref, String bikeId) {
  final db = ref.watch(databaseServiceProvider);
  return db.streamSettings(bikeId);
}

/// Provider for getting settings for a specific bike
/// This watches both Firestore stream and Hive for offline-first behavior
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  List<Setting> build(String bikeId) {
    // Listen to settings stream and sync to Hive
    ref.listen(settingsStreamProvider(bikeId), (previous, next) {
      next.when(
        data: (settings) {
          // Sync settings to Hive for offline access
          for (var setting in settings) {
            final settingId = '$bikeId-${setting.id}';
            HiveService().putIntoBox('settings', settingId, setting, false);
          }
          // Update state with new settings
          state = settings;
        },
        loading: () {
          // Keep current state while loading
        },
        error: (error, stack) {
          print('Error loading settings for $bikeId: $error');
          // Fall back to Hive data on error
          state = _getSettingsFromHive(bikeId);
        },
      );
    });

    // Return initial state from Hive (offline-first)
    return _getSettingsFromHive(bikeId);
  }

  /// Get settings from Hive
  List<Setting> _getSettingsFromHive(String bikeId) {
    final List<Setting> settingsList = [];
    final box = Hive.box<Setting>('settings');
    final boxKeys = box.keys;

    final bikeSettings = boxKeys.where((key) => key.toString().startsWith('$bikeId-'));
    for (final key in bikeSettings) {
      final setting = box.get(key);
      if (setting != null) {
        settingsList.add(setting);
      }
    }

    return settingsList;
  }

  /// Add or update a setting
  Future<void> addUpdateSetting(Setting setting) async {
    final settingId = '${setting.bike}-${setting.id}';

    // Save to Hive immediately for instant UI update
    HiveService().putIntoBox('settings', settingId, setting, true);

    // Update local state immediately
    final updatedSettings = List<Setting>.from(state);
    final existingIndex = updatedSettings.indexWhere((s) => s.id == setting.id);
    if (existingIndex >= 0) {
      updatedSettings[existingIndex] = setting;
    } else {
      updatedSettings.add(setting);
    }
    state = updatedSettings;

    // Sync to Firebase
    final db = ref.read(databaseServiceProvider);
    await db.updateSetting(setting);
  }

  /// Delete a setting
  Future<void> deleteSetting(String settingId) async {
    final key = '$bikeId-$settingId';

    // Delete from Hive
    Hive.box<Setting>('settings').delete(key);

    // Update local state immediately
    state = state.where((s) => s.id != settingId).toList();

    // Sync to Firebase
    final db = ref.read(databaseServiceProvider);
    await db.deleteSetting(bikeId, settingId);
  }
}
