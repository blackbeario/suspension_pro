import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suspension_pro/features/bikes/domain/models/bike.dart';
import 'package:suspension_pro/features/bikes/domain/models/setting.dart';
import 'package:suspension_pro/core/models/user_singleton.dart';
import 'package:suspension_pro/core/services/db_service.dart';
import 'package:suspension_pro/core/services/hive_service.dart';

class BikesBloc {
  final db = DatabaseService();
  final String uid = UserSingleton().uid;
  late String downloadUrl;

  /// Get from gallery
  getFromGallery(bikeid) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    _cropImage(bikeid, pickedFile!.path);
  }

  /// Crop Image
  _cropImage(bikeid, filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      compressQuality: 50,
    );
    if (croppedImage != null) {
      _uploadBikeImageToFirebase(bikeid, File(croppedImage.path));
    }
  }

  _uploadBikeImageToFirebase(bikeid, File imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('userImages/$uid/bikes/$bikeid/bike.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    uploadTask.whenComplete(() async {
      downloadUrl = await ref.getDownloadURL();
      db.setBikePic(bikeid, downloadUrl);
    }).catchError((error) {
      print(error);
      return error;
    });
  }

  String parseBikeName(Bike bike) {
    if (bike.yearModel != null) {
      return bike.yearModel.toString() + ' ' + bike.id;
    } else {
      return bike.id;
    }
  }

  getBikeSettingsFromHive(String bikeId) async {
    List<String> keysList = [];
    List<Setting> settingsList = [];
    var box = Hive.box<Setting>('settings');
    var boxKeys = box.keys;
    // var results = await box.get;
    for (var key in boxKeys) keysList.add(key);
    var bikeSettings = keysList.where((String key) => key.contains(bikeId));
    for (String key in bikeSettings) {
      Setting setting = box.get(key)!;
      settingsList.add(setting);
    }
    return settingsList;
  }

  putAllFirebaseSettingsIntoHive(String bikeId) async {
    Stream<List<Setting>> settingsStream = await db.streamSettings(bikeId);
    await for (List<Setting> settingsList in settingsStream) {
      for (Setting setting in settingsList) {
        final String settingId = bikeId + '-' + setting.id;
        HiveService().putIntoBox('settings', settingId, setting, false);
      }
    }
  }
}
