import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/bikes/domain/models/component_setting.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/features/bikes/domain/settings_notifier.dart';

part 'setting_detail_view_model.g.dart';

@riverpod
class SettingDetailViewModel extends _$SettingDetailViewModel {
  @override
  void build() {
    // Stateless view model
  }

  /// Save or update a setting
  /// Handles rename logic (delete old + create new)
  Future<void> saveSetting({
    required String bikeId,
    required String settingName,
    required String? originalSettingId,
    required String hscFork,
    required String lscFork,
    required String hsrFork,
    required String lsrFork,
    required String springRateFork,
    required String frontTire,
    required String hscShock,
    required String lscShock,
    required String hsrShock,
    required String lsrShock,
    required String springRateShock,
    required String rearTire,
    required String notes,
  }) async {
    final settingsNotifier = ref.read(settingsNotifierProvider(bikeId).notifier);

    // If editing and the name changed, delete the old setting first (rename logic)
    if (originalSettingId != null && originalSettingId != settingName) {
      await settingsNotifier.deleteSetting(originalSettingId);
    }

    // Create the setting with all values
    final setting = Setting(
      id: settingName,
      bike: bikeId,
      fork: ComponentSetting(
        hsc: hscFork,
        lsc: lscFork,
        hsr: hsrFork,
        lsr: lsrFork,
        springRate: springRateFork,
      ),
      shock: ComponentSetting(
        hsc: hscShock,
        lsc: lscShock,
        hsr: hsrShock,
        lsr: lsrShock,
        springRate: springRateShock,
      ),
      frontTire: frontTire,
      rearTire: rearTire,
      notes: notes,
    );

    // Save to storage (Hive + Firebase if Pro)
    await settingsNotifier.addUpdateSetting(setting);
  }

  /// Validate setting name
  String? validateSettingName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please add a setting title';
    }
    return null;
  }
}
