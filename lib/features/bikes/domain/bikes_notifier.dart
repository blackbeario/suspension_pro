import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/core/services/hive_service.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/features/bikes/domain/bikes_state.dart';
import 'package:hive_ce/hive.dart';

part 'bikes_notifier.g.dart';

/// Stream provider for bikes from Firestore
@riverpod
Stream<List<Bike>> bikesStream(Ref ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.streamBikes();
}

/// StateNotifier for managing bikes state and operations
@riverpod
class BikesNotifier extends _$BikesNotifier {
  @override
  BikesState build() {
    // Listen to bikes stream and update state
    final bikesStreamAsync = ref.watch(bikesStreamProvider);

    bikesStreamAsync.when(
      data: (bikes) {
        // Sync bikes to Hive for offline access
        for (var bike in bikes) {
          HiveService().putIntoBox('bikes', bike.id, bike, false);
          _syncBikeSettings(bike.id);
        }

        state = state.copyWith(
          bikes: bikes,
          isLoading: false,
          clearError: true,
        );
      },
      loading: () {
        state = state.copyWith(isLoading: true);
      },
      error: (error, stack) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );

    return const BikesState();
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

  /// Upload bike image from gallery
  Future<void> uploadBikeImage(String bikeId) async {
    try {
      state = state.copyWith(isSyncing: true);

      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
      );

      if (pickedFile == null) {
        state = state.copyWith(isSyncing: false);
        return;
      }

      await _cropAndUploadImage(bikeId, pickedFile.path);
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Failed to upload bike image: $e',
      );
    }
  }

  /// Crop and upload image to Firebase Storage
  Future<void> _cropAndUploadImage(String bikeId, String filePath) async {
    try {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: filePath,
        compressQuality: 50,
      );

      if (croppedImage != null) {
        await _uploadToFirebaseStorage(bikeId, File(croppedImage.path));
      } else {
        state = state.copyWith(isSyncing: false);
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Failed to crop image: $e',
      );
    }
  }

  /// Upload image file to Firebase Storage
  Future<void> _uploadToFirebaseStorage(String bikeId, File imageFile) async {
    try {
      final uid = ref.read(userNotifierProvider).uid;
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref().child('userImages/$uid/bikes/$bikeId/bike.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        final downloadUrl = await storageRef.getDownloadURL();
        final db = ref.read(databaseServiceProvider);
        await db.setBikePic(bikeId, downloadUrl);

        state = state.copyWith(isSyncing: false);
      });
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Failed to upload to Firebase: $e',
      );
    }
  }

  /// Parse bike name with year model
  String parseBikeName(Bike bike) {
    if (bike.yearModel != null) {
      return '${bike.yearModel} ${bike.id}';
    }
    return bike.id;
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for offline bikes from Hive
@riverpod
List<Bike> offlineBikes(OfflineBikesRef ref) {
  final box = Hive.box<Bike>('bikes');
  return box.values.toList();
}
