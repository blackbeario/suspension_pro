import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:suspension_pro/services/db_service.dart';

class Uploader extends StatefulWidget {
  Uploader({required this.uid, required this.file});

  final String uid;
  final File file;
  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  FirebaseStorage storage =
      FirebaseStorage.instanceFor(bucket: 'gs://suspension-pro.appspot.com/');
  final db = DatabaseService();
  late String downloadUrl = '';

  /// Starts an upload task
  _uploadToFirebase(uid, File imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('userImages/${widget.uid}/profile.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    uploadTask.whenComplete(() async {
      downloadUrl = await ref.getDownloadURL();

      /// Set the profilePic path in the user collection, which will trigger
      /// a change in the stream and the Profile Avatar should be refreshed.
      db.setProfilePic(widget.uid, downloadUrl);
      Navigator.pop(context);
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      _uploadToFirebase(widget.uid, widget.file);
      return Center(child: CupertinoActivityIndicator(animating: true));
    });
  }
}
