import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/features/bikes/domain/bikes_notifier.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/fork.dart';
import 'package:ridemetrx/features/bikes/domain/models/shock.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';

part 'bike_form_view_model.g.dart';

@riverpod
class BikeFormViewModel extends _$BikeFormViewModel {
  @override
  void build() {
    // Stateless view model
  }

  /// Save or update a bike
  /// Handles Hive storage, Pro/Free user logic, and Firebase sync
  Future<bool> saveBike({
    required String bikeName,
    required int yearModel,
    Fork? fork,
    Shock? shock,
  }) async {
    final box = Hive.box<Bike>('bikes');
    final now = DateTime.now();

    // Check if user has Pro subscription
    final isPro = ref.read(purchaseNotifierProvider).isPro;

    // Create bike with appropriate flags
    final bike = Bike(
      id: bikeName,
      yearModel: yearModel,
      fork: fork,
      shock: shock,
      lastModified: now,
      isDirty: !isPro, // Free users are dirty (local-only), Pro users start clean
    );

    // Save to Hive immediately for instant UI update
    box.put(bikeName, bike);
    print('BikeFormViewModel: Saved bike ${bike.id} to Hive');

    // Refresh BikesNotifier state from Hive to trigger UI update
    ref.read(bikesNotifierProvider.notifier).refreshFromHive();

    // Only sync to Firebase if user is Pro
    if (!isPro) {
      print('BikeFormViewModel: User is not Pro, bike ${bike.id} saved locally only');
      return false;
    }

    // Try to sync to Firebase (Pro users only)
    try {
      final db = ref.read(databaseServiceProvider);
      await db.addUpdateBike(bike);
      print('BikeFormViewModel: Successfully synced bike ${bike.id} to Firebase');
      return true;
    } catch (e) {
      // Firebase sync failed - mark as dirty for later sync
      print('BikeFormViewModel: Failed to sync bike ${bike.id} to Firebase: $e');
      print('BikeFormViewModel: Marking bike as dirty for later sync');

      final dirtyBike = Bike(
        id: bike.id,
        yearModel: bike.yearModel,
        fork: bike.fork,
        shock: bike.shock,
        index: bike.index,
        bikePic: bike.bikePic,
        lastModified: now,
        isDirty: true, // Mark as dirty
      );

      // Re-save to Hive with dirty flag
      box.put(bikeName, dirtyBike);

      // Refresh again with dirty version
      ref.read(bikesNotifierProvider.notifier).refreshFromHive();

      return false;
    }
  }

  /// Validate bike name (minimum 6 characters)
  String? validateBikeName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter bike model';
    }
    if (value.length < 6) {
      return 'Minimum 6 characters';
    }
    return null;
  }

  /// Validate year (4 digits)
  String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter year';
    }
    if (value.length != 4) {
      return '4 digits required';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Invalid year';
    }
    return null;
  }

  /// Check if form field meets length requirement
  bool meetsLengthRequirement(String value, int requirement) {
    return value.length >= requirement;
  }
}
