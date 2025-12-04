import 'package:ridemetrx/features/community/domain/models/community_setting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/features/bikes/domain/settings_notifier.dart';

part 'settings_list_view_model.g.dart';

@riverpod
class SettingsListViewModel extends _$SettingsListViewModel {
  @override
  void build() {
    // Stateless view model
  }

  /// Clone a setting with a new name
  Future<bool> cloneSetting({
    required Setting originalSetting,
    required String newName,
    required String bikeId,
  }) async {
    try {
      final settingsNotifier = ref.read(settingsNotifierProvider(bikeId).notifier);

      final clonedSetting = Setting(
        id: newName,
        bike: originalSetting.bike,
        fork: originalSetting.fork,
        shock: originalSetting.shock,
        frontTire: originalSetting.frontTire,
        rearTire: originalSetting.rearTire,
        notes: originalSetting.notes,
        riderWeight: originalSetting.riderWeight,
      );

      await settingsNotifier.addUpdateSetting(clonedSetting);
      return true;
    } catch (e) {
      print('SettingsListViewModel: Failed to clone setting: $e');
      return false;
    }
  }

  /// Create new setting from imported community setting
  Future<bool> importCommunitySetting({
    required CommunitySetting communitySetting,
    required String newName,
    required String bikeId,
  }) async {
    try {
      final settingsNotifier = ref.read(settingsNotifierProvider(bikeId).notifier);

      final importedSetting = Setting(
        id: newName,
        bike: bikeId,
        fork: communitySetting.forkSettings,
        shock: communitySetting.shockSettings,
        frontTire: communitySetting.frontTire,
        rearTire: communitySetting.rearTire,
        notes: communitySetting.notes,
        riderWeight: communitySetting.riderWeight,
      );

      await settingsNotifier.addUpdateSetting(importedSetting);
      return true;
    } catch (e) {
      print('SettingsListViewModel: Failed to import setting: $e');
      return false;
    }
  }

  /// Delete a setting
  Future<void> deleteSetting({
    required String settingId,
    required String bikeId,
  }) async {
    final settingsNotifier = ref.read(settingsNotifierProvider(bikeId).notifier);
    await settingsNotifier.deleteSetting(settingId);
  }

  /// Format product name for fork
  String formatForkProduct(Bike bike) {
    final fork = bike.fork;
    if (fork == null) return '';
    return '${fork.year} ${fork.brand} ${fork.model}';
  }

  /// Format product name for shock
  String formatShockProduct(Bike bike) {
    final shock = bike.shock;
    if (shock == null) return '';
    return '${shock.year} ${shock.brand} ${shock.model}';
  }

  /// Generate default clone name
  String generateCloneName(String originalName) {
    return '$originalName (Copy)';
  }

  /// Reorder settings and save to Hive and Firebase
  Future<void> reorderSettings(List<Setting> settings, String bikeId) async {
    final settingsNotifier = ref.read(settingsNotifierProvider(bikeId).notifier);

    // Save each setting with its new index
    for (final setting in settings) {
      await settingsNotifier.addUpdateSetting(setting);
    }
  }
}
