import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';

part 'bike_image_view_model.g.dart';

@riverpod
class BikeImageViewModel extends _$BikeImageViewModel {
  @override
  void build() {
    // Stateless view model
  }

  /// Upload bike image from gallery
  /// Handles image picking, cropping, and uploading to Firebase Storage
  Future<bool> uploadBikeImage(String bikeId) async {
    try {
      // Pick image from gallery
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
      );

      if (pickedFile == null) {
        return false; // User cancelled
      }

      // Crop and upload
      return await _cropAndUploadImage(bikeId, pickedFile.path);
    } catch (e) {
      print('BikeImageViewModel: Failed to upload bike image: $e');
      return false;
    }
  }

  /// Crop and upload image to Firebase Storage
  Future<bool> _cropAndUploadImage(String bikeId, String filePath) async {
    try {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: filePath,
        compressQuality: 50,
      );

      if (croppedImage != null) {
        return await _uploadToFirebaseStorage(bikeId, File(croppedImage.path));
      }

      return false; // User cancelled crop
    } catch (e) {
      print('BikeImageViewModel: Failed to crop image: $e');
      return false;
    }
  }

  /// Upload image file to Firebase Storage
  Future<bool> _uploadToFirebaseStorage(String bikeId, File imageFile) async {
    try {
      final uid = ref.read(userNotifierProvider).uid;
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref().child('userImages/$uid/bikes/$bikeId/bike.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        final downloadUrl = await storageRef.getDownloadURL();
        final db = ref.read(databaseServiceProvider);
        await db.setBikePic(bikeId, downloadUrl);
      });

      return true;
    } catch (e) {
      print('BikeImageViewModel: Failed to upload to Firebase: $e');
      return false;
    }
  }
}
