import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'imageCapture.dart';

// ignore: must_be_immutable
class ImageActionSheet extends StatelessWidget {
  ImageActionSheet({required this.uid});
  final String uid;
  late Function(File val) file;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
      actions: <Widget>[
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
              Navigator.pop(context); // Dismiss the CupertinoModal first.
              Navigator.of(context).push(
                // Then push the camera route onto the stack.
                CupertinoPageRoute(
                    fullscreenDialog: true, // loads form from bottom
                    builder: (context) {
                      return ImageCapture(
                          source: ImageSource.camera, uid: this.uid);
                    }),
              );
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
            Navigator.pop(context); // Dismiss the CupertinoModal first.
            Navigator.of(context).push(
              // Then push the gallery route onto the stack.
              CupertinoPageRoute(
                  fullscreenDialog: true, // loads from bottom
                  builder: (context) {
                    return ImageCapture(
                        source: ImageSource.gallery, uid: uid);
                  }),
            );
          },
        ),
      ],
    );
  }
}