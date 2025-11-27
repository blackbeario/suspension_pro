import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';

class ImageActionSheet extends ConsumerStatefulWidget {
  const ImageActionSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageActionSheet> createState() => _ImageActionSheetState();
}

class _ImageActionSheetState extends ConsumerState<ImageActionSheet> {
  FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'gs://suspension-pro.appspot.com/');
  String downloadUrl = '';
  File? _imageFile;

  /// Get from camera
  _getFromCamera() async {
    print('ImageActionSheet: Getting from camera');
    // Capture uid and db before async operations (before widget unmounts)
    final uid = ref.read(userNotifierProvider).uid;
    final db = ref.read(databaseServiceProvider);

    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 300,
        maxHeight: 300,
      );
      print('ImageActionSheet: Picked file from camera: ${pickedFile?.path}');
      if (pickedFile != null) {
        // Don't check mounted - we have the data we need and can proceed
        await _cropImage(pickedFile.path, uid, db);
      }
    } catch (e) {
      print('ImageActionSheet: Error getting from camera: $e');
    }
  }

  /// Get from gallery
  _getFromGallery() async {
    print('ImageActionSheet: Getting from gallery');
    // Capture uid and db before async operations (before widget unmounts)
    final uid = ref.read(userNotifierProvider).uid;
    final db = ref.read(databaseServiceProvider);

    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
      );
      print('ImageActionSheet: Picked file from gallery: ${pickedFile?.path}');
      if (pickedFile != null) {
        // Don't check mounted - we have the data we need and can proceed
        await _cropImage(pickedFile.path, uid, db);
      }
    } catch (e) {
      print('ImageActionSheet: Error getting from gallery: $e');
    }
  }

  /// Crop Image
  Future<void> _cropImage(String filePath, String uid, dynamic db) async {
    print('ImageActionSheet: Cropping image from: $filePath');
    try {
      final CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: filePath,
        compressQuality: 50,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockDimensionSwapEnabled: false,
            cropStyle: CropStyle.circle,
          ),
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            cropStyle: CropStyle.circle,
            lockAspectRatio: true,
          ),
        ],
      );
      print('ImageActionSheet: Cropped image: ${croppedImage?.path}');
      if (croppedImage != null) {
        // Don't check mounted - we can still upload even if widget is unmounted
        _imageFile = File(croppedImage.path);
        await _uploadProfileImageToFirebase(uid, _imageFile!, db);
      } else {
        print('ImageActionSheet: Crop cancelled by user');
      }
    } catch (e) {
      print('ImageActionSheet: Error cropping image: $e');
    }
  }

  Future<void> _uploadProfileImageToFirebase(String uid, File imageFile, dynamic db) async {
    print('ImageActionSheet: Uploading to Firebase for uid: $uid');
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageRef = storage.ref().child('userImages/$uid/profile.jpg');
      UploadTask uploadTask = storageRef.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        downloadUrl = await storageRef.getDownloadURL();
        print('ImageActionSheet: Upload complete, URL: $downloadUrl');
        await db.setProfilePic(downloadUrl);
        print('ImageActionSheet: Profile pic updated in database');
      });
    } catch (e) {
      print('ImageActionSheet: Error uploading to Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(CupertinoIcons.photo_camera, size: 32),
                SizedBox(width: 10),
                Text('Camera'),
              ],
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _getFromCamera();
            }),
        CupertinoActionSheetAction(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(CupertinoIcons.collections, size: 26),
              SizedBox(width: 10),
              Text('Photo Library'),
            ],
          ),
          onPressed: () async {
            Navigator.pop(context);
            await _getFromGallery();
          },
        ),
      ],
    );
  }
}
