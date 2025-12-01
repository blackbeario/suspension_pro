import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_service.g.dart';

/// Service for syncing dirty Hive data to Firebase
/// Only syncs for Pro subscribers
@riverpod
class SyncService extends _$SyncService {
  @override
  bool build() {
    // Initial state: not syncing
    return false;
  }

  /// Sync all dirty data from Hive to Firebase
  /// Only syncs if user has active Pro subscription
  Future<void> syncDirtyData() async {
    // Check if user has Pro subscription
    final isPro = ref.read(purchaseNotifierProvider).isPro;
    if (!isPro) {
      // Free users stay local-only
      print('SyncService: User is not Pro, skipping cloud sync');
      return;
    }

    state = true; // Set syncing state

    try {
      await _syncDirtyBikes();
      await _syncDirtySettings();
      print('SyncService: Sync completed successfully');
    } catch (e) {
      print('SyncService: Sync failed: $e');
      // TODO: Implement retry logic with exponential backoff
    } finally {
      state = false; // Reset syncing state
    }
  }

  /// Sync dirty bikes to Firebase
  Future<void> _syncDirtyBikes() async {
    final bikesBox = Hive.box<Bike>('bikes');
    final db = ref.read(databaseServiceProvider);

    final dirtyBikes = bikesBox.values.where((bike) => bike.isDirty).toList();

    if (dirtyBikes.isEmpty) {
      print('SyncService: No dirty bikes to sync');
      return;
    }

    print('SyncService: Syncing ${dirtyBikes.length} dirty bikes');

    for (final bike in dirtyBikes) {
      try {
        if (bike.isDeleted) {
          // This is a tombstone - delete from Firebase
          await db.deleteBike(bike.id);
          print('SyncService: Deleted bike ${bike.id} from Firebase');

          // Remove tombstone from Hive
          await bikesBox.delete(bike.id);
          print('SyncService: Removed tombstone for bike ${bike.id}');
        } else {
          // Normal update - push to Firebase
          await db.addUpdateBike(bike);

          // Mark as clean in Hive
          final cleanBike = Bike(
            id: bike.id,
            yearModel: bike.yearModel,
            fork: bike.fork,
            shock: bike.shock,
            index: bike.index,
            bikePic: bike.bikePic,
            lastModified: bike.lastModified,
            isDirty: false, // Mark as clean
            isDeleted: false,
          );

          await bikesBox.put(bike.id, cleanBike);
          print('SyncService: Synced bike ${bike.id}');
        }
      } catch (e) {
        print('SyncService: Failed to sync bike ${bike.id}: $e');
        // Keep dirty flag so it retries next time
      }
    }
  }

  /// Sync dirty settings to Firebase
  Future<void> _syncDirtySettings() async {
    final settingsBox = Hive.box<Setting>('settings');
    final db = ref.read(databaseServiceProvider);

    final dirtySettings = settingsBox.values.where((setting) => setting.isDirty).toList();

    if (dirtySettings.isEmpty) {
      print('SyncService: No dirty settings to sync');
      return;
    }

    print('SyncService: Syncing ${dirtySettings.length} dirty settings');

    for (final setting in dirtySettings) {
      try {
        // Extract bike ID from setting key (format: "bikeId-settingId")
        final bikeId = setting.bike ?? '';
        if (bikeId.isEmpty) continue;

        final settingKey = '$bikeId-${setting.id}';

        if (setting.isDeleted) {
          // This is a tombstone - delete from Firebase
          await db.deleteSetting(bikeId, setting.id);
          print('SyncService: Deleted setting $settingKey from Firebase');

          // Remove tombstone from Hive
          await settingsBox.delete(settingKey);
          print('SyncService: Removed tombstone for setting $settingKey');
        } else {
          // Normal update - push to Firebase
          await db.updateSetting(setting);

          // Mark as clean in Hive
          final cleanSetting = Setting(
            id: setting.id,
            bike: setting.bike,
            fork: setting.fork,
            shock: setting.shock,
            riderWeight: setting.riderWeight,
            updated: setting.updated,
            frontTire: setting.frontTire,
            rearTire: setting.rearTire,
            notes: setting.notes,
            lastModified: setting.lastModified,
            isDirty: false, // Mark as clean
            isDeleted: false,
          );

          await settingsBox.put(settingKey, cleanSetting);
          print('SyncService: Synced setting $settingKey');
        }
      } catch (e) {
        print('SyncService: Failed to sync setting ${setting.id}: $e');
        // Keep dirty flag so it retries next time
      }
    }
  }

  /// Force sync all data (regardless of dirty flag)
  /// Used for testing or manual "Push to Cloud" action
  Future<void> forceSyncAll() async {
    final isPro = ref.read(purchaseNotifierProvider).isPro;
    if (!isPro) {
      throw Exception('Pro subscription required for cloud sync');
    }

    state = true;

    try {
      final db = ref.read(databaseServiceProvider);

      // Sync all bikes
      final bikesBox = Hive.box<Bike>('bikes');
      for (final bike in bikesBox.values) {
        await db.addUpdateBike(bike);
      }

      // Sync all settings
      final settingsBox = Hive.box<Setting>('settings');
      for (final setting in settingsBox.values) {
        final bikeId = setting.bike ?? '';
        if (bikeId.isNotEmpty) {
          await db.updateSetting(setting);
        }
      }

      print('SyncService: Force sync completed');
    } finally {
      state = false;
    }
  }
}
