import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/core/services/hive_service.dart';
import 'package:ridemetrx/features/bikes/domain/bikes_state.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:hive_ce/hive.dart';

part 'bikes_notifier.g.dart';

/// Stream provider for bikes from Firestore (Pro users only)
@riverpod
Stream<List<Bike>> bikesStream(Ref ref) {
  // Only stream from Firebase if user is Pro
  final userState = ref.watch(userNotifierProvider);

  if (!userState.isPro) {
    // Free users: return empty stream (use Hive only)
    return Stream.value([]);
  }

  // Pro users: stream from Firebase
  final db = ref.watch(databaseServiceProvider);
  return db.streamBikes();
}

/// StateNotifier for managing bikes state and operations
@riverpod
class BikesNotifier extends _$BikesNotifier {
  @override
  BikesState build() {
    // IMPORTANT: Load bikes from Hive immediately on initialization
    // This ensures bikes are available right away for import dialogs, etc.
    final initialBikes = _getBikesFromHive();

    // Listen to bikes stream and smart-merge with Hive
    ref.listen(bikesStreamProvider, (previous, next) {
      next.when(
        data: (firebaseBikes) {
          // Smart merge bikes from Firebase into Hive
          _smartMergeBikes(firebaseBikes);

          // Sync settings for each bike
          for (var bike in firebaseBikes) {
            _syncBikeSettings(bike.id);
          }

          // Update state from Hive (source of truth)
          final hiveBikes = _getBikesFromHive();
          state = state.copyWith(
            bikes: hiveBikes,
            isLoading: false,
            clearError: true,
          );
        },
        loading: () {
          state = state.copyWith(isLoading: true);
        },
        error: (error, stack) {
          print('BikesNotifier: Error loading bikes: $error');
          // Fall back to Hive data
          final hiveBikes = _getBikesFromHive();
          state = state.copyWith(
            bikes: hiveBikes,
            isLoading: false,
            errorMessage: error.toString(),
          );
        },
      );
    });

    // Return initial state with bikes from Hive
    return BikesState(bikes: initialBikes);
  }

  /// Smart merge Firebase bikes into Hive (same logic as settings)
  void _smartMergeBikes(List<Bike> firebaseBikes) {
    final box = Hive.box<Bike>('bikes');

    for (final firebaseBike in firebaseBikes) {
      final hiveBike = box.get(firebaseBike.id);

      if (hiveBike == null) {
        // New bike from another device → add to Hive
        print('BikesNotifier: New bike from Firebase: ${firebaseBike.id}');
        box.put(firebaseBike.id, firebaseBike);
      } else if (hiveBike.isDeleted) {
        // Local has tombstone → ignore Firebase data
        print('BikesNotifier: Ignoring Firebase bike ${firebaseBike.id} (locally deleted)');
      } else if (hiveBike.isDirty) {
        // Local has unsync'd changes → keep local
        print('BikesNotifier: Keeping local dirty bike ${firebaseBike.id}');
      } else {
        // Hive is clean → accept Firebase update
        final hiveTime = hiveBike.lastModified ?? DateTime(2000);
        final firebaseTime = firebaseBike.lastModified ?? DateTime(2000);

        if (firebaseTime.isAfter(hiveTime) || firebaseTime == hiveTime) {
          print('BikesNotifier: Updating bike ${firebaseBike.id} from Firebase');
          box.put(firebaseBike.id, firebaseBike);
        }
      }
    }
  }

  /// Get bikes from Hive (excludes deleted items)
  List<Bike> _getBikesFromHive() {
    final box = Hive.box<Bike>('bikes');
    return box.values.where((bike) => !bike.isDeleted).toList();
  }

  /// Sync bike settings from Firebase to Hive
  Future<void> _syncBikeSettings(String bikeId) async {
    final db = ref.read(databaseServiceProvider);
    try {
      final settingsStream = await db.streamSettings(bikeId);
      await for (final settingsList in settingsStream) {
        for (final setting in settingsList) {
          final settingId = '$bikeId-${setting.id}';
          HiveService().putIntoBox('settings', settingId, setting, false);
        }
        // Only process first emission, then break
        break;
      }
    } catch (e) {
      print('Error syncing bike settings for $bikeId: $e');
    }
  }

  /// Get bike settings from Hive (offline-first)
  Future<List<Setting>> getBikeSettings(String bikeId) async {
    final List<Setting> settingsList = [];
    final box = Hive.box<Setting>('settings');
    final boxKeys = box.keys;

    final bikeSettings = boxKeys.where((key) => key.toString().contains(bikeId));
    for (final key in bikeSettings) {
      final setting = box.get(key);
      if (setting != null) {
        settingsList.add(setting);
      }
    }

    return settingsList;
  }

  /// Delete a bike (uses tombstone pattern for sync safety)
  Future<void> deleteBike(String bikeId) async {
    final bikeBox = Hive.box<Bike>('bikes');
    final bike = bikeBox.get(bikeId);

    if (bike == null) {
      print('BikesNotifier: Bike $bikeId not found');
      return;
    }

    final now = DateTime.now();

    // Mark as deleted (tombstone) instead of actually deleting
    final deletedBike = Bike(
      id: bike.id,
      yearModel: bike.yearModel,
      fork: bike.fork,
      shock: bike.shock,
      index: bike.index,
      bikePic: bike.bikePic,
      lastModified: now,
      isDirty: true, // Mark as dirty so it syncs
      isDeleted: true, // TOMBSTONE
    );

    // Save tombstone to Hive
    bikeBox.put(bikeId, deletedBike);

    // Update UI state immediately (remove from visible bikes)
    final updatedBikes = state.bikes.where((b) => b.id != bikeId).toList();
    state = state.copyWith(bikes: updatedBikes);

    // Check if user is Pro before syncing to Firebase
    final isPro = ref.read(purchaseNotifierProvider).isPro;
    if (!isPro) {
      print('BikesNotifier: User is not Pro, bike $bikeId deleted locally only (tombstone saved)');
      return;
    }

    // Try to sync deletion to Firebase (Pro users only)
    try {
      final db = ref.read(databaseServiceProvider);
      await db.deleteBike(bikeId);
      print('BikesNotifier: Successfully deleted bike $bikeId from Firebase');

      // Successfully synced deletion - now we can remove the tombstone from Hive
      bikeBox.delete(bikeId);
    } catch (e) {
      // Firebase delete failed - tombstone will be synced later by SyncService
      print('BikesNotifier: Failed to delete bike $bikeId from Firebase: $e');
      print('BikesNotifier: Tombstone saved, will sync deletion when connectivity restored');
    }
  }

  /// Refresh bikes state from Hive (for when bikes are added/updated outside Firebase stream)
  void refreshFromHive() {
    final hiveBikes = _getBikesFromHive();
    state = state.copyWith(bikes: hiveBikes, clearError: true);
    print('BikesNotifier: Refreshed state from Hive - ${hiveBikes.length} bikes');
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for offline bikes from Hive (excludes deleted items)
@riverpod
List<Bike> offlineBikes(Ref ref) {
  final box = Hive.box<Bike>('bikes');
  return box.values.where((bike) => !bike.isDeleted).toList();
}
