import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/core/services/hive_service.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';
import 'package:hive_ce/hive.dart';

part 'settings_notifier.g.dart';

/// Stream provider for settings from Firestore for a specific bike
/// Only streams if user is Pro
@riverpod
Stream<List<Setting>> settingsStream(Ref ref, String bikeId) {
  final isPro = ref.watch(purchaseNotifierProvider).isPro;

  if (!isPro) {
    // Free users: return empty stream, no Firebase access
    return Stream.value([]);
  }

  final db = ref.watch(databaseServiceProvider);
  return db.streamSettings(bikeId);
}

/// Provider for getting settings for a specific bike
/// This watches both Firestore stream and Hive for offline-first behavior
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  List<Setting> build(String bikeId) {
    final isPro = ref.watch(purchaseNotifierProvider).isPro;

    // Only listen to Firebase stream if user is Pro
    if (isPro) {
      ref.listen(settingsStreamProvider(bikeId), (previous, next) {
        next.when(
          data: (firebaseSettings) {
            // Smart merge: Don't blindly accept Firebase data
            _smartMergeSettings(bikeId, firebaseSettings);
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
    }

    // Return initial state from Hive (offline-first)
    return _getSettingsFromHive(bikeId);
  }

  /// Smart merge Firebase data into Hive with conflict detection
  void _smartMergeSettings(String bikeId, List<Setting> firebaseSettings) {
    final box = Hive.box<Setting>('settings');
    bool hiveDirty = false;

    for (final firebaseSetting in firebaseSettings) {
      final settingKey = '$bikeId-${firebaseSetting.id}';
      final hiveSetting = box.get(settingKey);

      if (hiveSetting == null) {
        // New setting from another device → add to Hive
        print('SettingsNotifier: New setting from Firebase: ${firebaseSetting.id}');
        box.put(settingKey, firebaseSetting);
        hiveDirty = true;
      } else if (hiveSetting.isDeleted) {
        // Local has tombstone → ignore Firebase data
        print('SettingsNotifier: Ignoring Firebase setting ${firebaseSetting.id} (locally deleted)');
        // Don't overwrite tombstone
      } else if (hiveSetting.isDirty) {
        // Local has unsync'd changes → check for conflict
        final hiveTime = hiveSetting.lastModified ?? DateTime(2000);
        final firebaseTime = firebaseSetting.lastModified ?? DateTime(2000);

        if (hiveTime.isAfter(firebaseTime)) {
          // Local is newer → keep local, will sync up later
          print('SettingsNotifier: Local setting ${firebaseSetting.id} is newer, keeping local');
        } else {
          // Firebase is newer → CONFLICT!
          print('SettingsNotifier: CONFLICT detected for setting ${firebaseSetting.id}');
          // TODO: Add to conflict queue
          // For now, keep local version (user explicitly edited it)
        }
      } else {
        // Hive is clean → accept Firebase update
        final hiveTime = hiveSetting.lastModified ?? DateTime(2000);
        final firebaseTime = firebaseSetting.lastModified ?? DateTime(2000);

        if (firebaseTime.isAfter(hiveTime)) {
          print('SettingsNotifier: Updating setting ${firebaseSetting.id} from Firebase');
          box.put(settingKey, firebaseSetting);
          hiveDirty = true;
        }
      }
    }

    // CRITICAL: Always update state from Hive, NOT from Firebase
    // This ensures UI shows local truth (including tombstones being hidden)
    if (hiveDirty || state.isEmpty) {
      state = _getSettingsFromHive(bikeId);
    }
  }

  /// Get settings from Hive (excludes deleted items)
  List<Setting> _getSettingsFromHive(String bikeId) {
    final List<Setting> settingsList = [];
    final box = Hive.box<Setting>('settings');
    final boxKeys = box.keys;

    final bikeSettings = boxKeys.where((key) => key.toString().startsWith('$bikeId-'));

    for (final key in bikeSettings) {
      final setting = box.get(key);
      // Skip deleted items
      if (setting != null && !setting.isDeleted) {
        settingsList.add(setting);
      }
    }

    // Sort by index (settings without index go to the end)
    settingsList.sort((a, b) {
      if (a.index == null && b.index == null) return 0;
      if (a.index == null) return 1;
      if (b.index == null) return -1;
      return a.index!.compareTo(b.index!);
    });

    return settingsList;
  }

  /// Add or update a setting
  Future<void> addUpdateSetting(Setting setting) async {
    final settingId = '${setting.bike}-${setting.id}';
    final now = DateTime.now();

    // Check if user has Pro subscription
    final isPro = ref.read(purchaseNotifierProvider).isPro;

    // Determine index: use provided index, or assign next available
    int? settingIndex = setting.index;
    if (settingIndex == null) {
      // Find the highest index and add 1
      final currentSettings = state;
      if (currentSettings.isNotEmpty) {
        final maxIndex = currentSettings
            .where((s) => s.index != null)
            .fold<int>(
              -1,
              (max, s) => s.index! > max ? s.index! : max,
            );
        settingIndex = maxIndex + 1;
      } else {
        settingIndex = 0;
      }
    }

    // Create setting with appropriate flags
    final settingWithTimestamp = Setting(
      id: setting.id,
      bike: setting.bike,
      fork: setting.fork,
      shock: setting.shock,
      riderWeight: setting.riderWeight,
      updated: setting.updated,
      frontTire: setting.frontTire,
      rearTire: setting.rearTire,
      notes: setting.notes,
      lastModified: now,
      isDirty: !isPro, // Free users are dirty (local-only), Pro users start clean
      isDeleted: false,
      index: settingIndex,
    );

    // Save to Hive immediately for instant UI update
    HiveService().putIntoBox('settings', settingId, settingWithTimestamp, true);

    // Update local state immediately
    final updatedSettings = List<Setting>.from(state);
    final existingIndex = updatedSettings.indexWhere((s) => s.id == setting.id);
    if (existingIndex >= 0) {
      updatedSettings[existingIndex] = settingWithTimestamp;
    } else {
      updatedSettings.add(settingWithTimestamp);
    }
    state = updatedSettings;

    // Only sync to Firebase if user is Pro
    if (!isPro) {
      print('SettingsNotifier: User is not Pro, setting $settingId saved locally only');
      return;
    }

    // Try to sync to Firebase (Pro users only)
    try {
      final db = ref.read(databaseServiceProvider);
      await db.updateSetting(settingWithTimestamp);
      print('SettingsNotifier: Successfully synced setting $settingId to Firebase');
    } catch (e) {
      // Firebase sync failed - mark as dirty for later sync
      print('SettingsNotifier: Failed to sync setting $settingId to Firebase: $e');
      print('SettingsNotifier: Marking setting as dirty for later sync');

      final dirtySettings = Setting(
        id: setting.id,
        bike: setting.bike,
        fork: setting.fork,
        shock: setting.shock,
        riderWeight: setting.riderWeight,
        updated: setting.updated,
        frontTire: setting.frontTire,
        rearTire: setting.rearTire,
        notes: setting.notes,
        lastModified: now,
        isDirty: true, // Mark as dirty
        isDeleted: false,
      );

      // Re-save to Hive with dirty flag
      HiveService().putIntoBox('settings', settingId, dirtySettings, true);

      // Update local state with dirty version
      final dirtyUpdatedSettings = List<Setting>.from(state);
      final dirtyExistingIndex = dirtyUpdatedSettings.indexWhere((s) => s.id == setting.id);
      if (dirtyExistingIndex >= 0) {
        dirtyUpdatedSettings[dirtyExistingIndex] = dirtySettings;
      } else {
        dirtyUpdatedSettings.add(dirtySettings);
      }
      state = dirtyUpdatedSettings;
    }
  }

  /// Delete a setting (uses tombstone pattern for sync safety)
  Future<void> deleteSetting(String settingId) async {
    final key = '$bikeId-$settingId';
    final box = Hive.box<Setting>('settings');
    final setting = box.get(key);

    if (setting == null) {
      print('SettingsNotifier: Setting $settingId not found');
      return;
    }

    final now = DateTime.now();

    // Mark as deleted (tombstone) instead of actually deleting
    final deletedSetting = Setting(
      id: setting.id,
      bike: setting.bike,
      fork: setting.fork,
      shock: setting.shock,
      riderWeight: setting.riderWeight,
      updated: setting.updated,
      frontTire: setting.frontTire,
      rearTire: setting.rearTire,
      notes: setting.notes,
      lastModified: now,
      isDirty: true, // Mark as dirty so it syncs
      isDeleted: true, // TOMBSTONE
    );

    // Save tombstone to Hive
    box.put(key, deletedSetting);

    // Update local state immediately (remove from UI)
    state = state.where((s) => s.id != settingId).toList();

    // Try to sync deletion to Firebase
    try {
      final db = ref.read(databaseServiceProvider);
      await db.deleteSetting(bikeId, settingId);
      print('SettingsNotifier: Successfully deleted setting $settingId from Firebase');

      // Successfully synced deletion - now we can remove the tombstone from Hive
      box.delete(key);
    } catch (e) {
      // Firebase delete failed - tombstone will be synced later by SyncService
      print('SettingsNotifier: Failed to delete setting $settingId from Firebase: $e');
      print('SettingsNotifier: Tombstone saved, will sync deletion when connectivity restored');
    }
  }
}
