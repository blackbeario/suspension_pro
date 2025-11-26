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

  /// Get from gallery
  _getFromCamera() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (pickedFile != null) _cropImage(pickedFile.path);
  }

  /// Get from gallery
  _getFromGallery() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (pickedFile != null) _cropImage(pickedFile.path);
  }

  /// Crop Image
  _cropImage(filePath) async {
    final uid = ref.read(userNotifierProvider).uid;
    final CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: filePath, compressQuality: 50);
    if (croppedImage != null) {
      _imageFile = File(croppedImage.path);
      _uploadProfileImageToFirebase(uid, _imageFile!);
    }
  }

  _uploadProfileImageToFirebase(String uid, File imageFile) async {
    final db = ref.read(databaseServiceProvider);
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageRef = storage.ref().child('userImages/$uid/profile.jpg');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    uploadTask.whenComplete(() async {
      downloadUrl = await storageRef.getDownloadURL();
      await db.setProfilePic(downloadUrl);
    }).catchError((onError) {
      throw onError;
    });
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
            onPressed: () {
              Navigator.pop(context);
              _getFromCamera();
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
          onPressed: () {
            Navigator.pop(context);
            _getFromGallery();
          },
        ),
      ],
    );
  }
}
