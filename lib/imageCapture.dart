import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suspension_pro/uploader.dart';

/// Widget to capture and crop the image
class ImageCapture extends StatefulWidget {
  ImageCapture({required this.source, required this.uid});
  final String uid;
  final ImageSource source;

  createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  /// Active image file
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pickImage(widget.source);
  }

  /// Select an image via gallery or camera
  Future<String?> _pickImage(ImageSource source) async {
    _imageFile = File(
      await _picker
          .pickImage(
              source: source, maxWidth: 300, maxHeight: 300, imageQuality: 80)
          .then((pickedFile) => pickedFile != null ? pickedFile.path : ''),
    );
    // ignore: unrelated_type_equality_checks
    if (_imageFile != null && _imageFile != '') {
      _cropImage(_imageFile!);
    }
  }

  /// Cropper plugin
  Future<void> _cropImage(File selectedFile) async {
    File? cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile!.path,
      maxWidth: 150,
      maxHeight: 150,
      aspectRatio: CropAspectRatio(ratioX: 20, ratioY: 20),
      cropStyle: CropStyle.circle,
      // compressQuality: 50
    );
    setState(() {
      _imageFile = cropped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Preview the image and crop it
            if (_imageFile != null) Uploader(uid: widget.uid, file: _imageFile!)
                else Padding(
                    padding: EdgeInsets.all(20),
                    child: Builder(builder: (context) {
                      // Navigator.pop(context);
                      return Center(
                        child: CupertinoActivityIndicator(animating: true),
                      );
                    }),
                  )
             
          ],
        ),
      ),
    );
  }
}
