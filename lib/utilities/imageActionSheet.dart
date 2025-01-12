import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'package:suspension_pro/services/db_service.dart';

// ignore: must_be_immutable
class ImageActionSheet extends StatelessWidget {
  final db = DatabaseService();

  ImageActionSheet();
  final String uid = UserSingleton().uid;
  FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'gs://suspension-pro.appspot.com/');
  late String downloadUrl = '';
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
    final CroppedFile? croppedImage =
        await ImageCropper().cropImage(cropStyle: CropStyle.circle, sourcePath: filePath, compressQuality: 50);
    if (croppedImage != null) {
      // UserSingleton().profilePic = croppedImage.path;
      _imageFile = File(croppedImage.path);
      _uploadToFirebase(uid, _imageFile!);
    }
  }

  _uploadToFirebase(uid, File imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('userImages/$uid/profile.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    uploadTask.whenComplete(() async {
      downloadUrl = await ref.getDownloadURL();
      UserSingleton().profilePic = downloadUrl;
      db.setProfilePic(downloadUrl);
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
