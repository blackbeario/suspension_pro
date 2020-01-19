import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import './models/user.dart';

class Profile extends StatelessWidget {
  Profile({Key key, @required this.uid}) : super(key: key);
  
  final String uid;
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: db.streamUser(this.uid),
      builder: (context, snapshot) {
        var myUser = snapshot.data;
        if (myUser == null) {
          return Center(
            child: CupertinoActivityIndicator(animating: true)
          );
        }
        return ProfileEdit(myUser: myUser, uid: this.uid);
      },
    );
  }
}


class ProfileEdit extends StatefulWidget {
  ProfileEdit({@required this.myUser, @required this.uid});
  final String uid;
  final User myUser;
  String profilePic;

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final db = DatabaseService();
  final AuthService auth = AuthService();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.myUser.username ?? '';
    _emailController.text = widget.myUser.email ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<bool> _updateUser(uid, BuildContext context) {
    // Navigator.pop(context);
    db.updateUser(uid, _usernameController.text, _emailController.text);
    return Future.value(false);
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.myUser.username),
        trailing: CupertinoButton(
          child: Icon(Icons.power_settings_new),
          onPressed: () => _requestPop(context)
        ),
      ),
      child: Material(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Stack(
                    alignment: AlignmentDirectional.topStart,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: CircleAvatar(
                          backgroundColor: CupertinoColors.activeBlue,
                          radius: 80,
                          child: CircleAvatar(
                            radius: 76,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            backgroundImage: widget.myUser.profilePic.length > 0 ? 
                              NetworkImage(widget.myUser.profilePic) : AssetImage("assets/roost.jpg"),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 88,
                        bottom: 30,
                        child: Icon(CupertinoIcons.photo_camera, color: Colors.white70)
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () => showCupertinoModalPopup(
                useRootNavigator: true,
                context: context,
                builder: (context) => ImageActionSheet(uid: widget.uid)
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: CupertinoTextField(
                // decoration: BoxDecoration(),
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                padding: EdgeInsets.all(10),
                placeholder: 'username',
                controller: _usernameController,
                keyboardType: TextInputType.text
              ),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: CupertinoTextField(
                // decoration: BoxDecoration(),
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                padding: EdgeInsets.all(10),
                placeholder: 'email',
                controller: _emailController,
                keyboardType: TextInputType.text
              ),
            ),
            // Show the role if user is admin. No sense in showing 'regular' user or whatevs.
            // If we elect to have tiered user pricing etc, we can easily show that status here.
            widget.myUser.role == 'admin' ? ListTile(
              leading: Icon(Icons.settings),
              title: Text(widget.myUser.role),
            ) : Container(),           
            // Expanded(child: Container()),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.only(left: 80, right: 80),
              child: CupertinoButton(
                disabledColor: CupertinoColors.quaternarySystemFill,
                color: CupertinoColors.activeBlue,
                child: Text('Save', style: TextStyle(color: Colors.white)),
                // TODO: Set a validation check and disable the save button unless valid.
                onPressed: ()=> _updateUser(widget.uid, context)
              ),
            ),
          ],
        ),
      )
    );
  }

  Future<bool> _requestPop(BuildContext context) {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Signout'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Okay'),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context, 'Discard');
              auth.signOut();
            }
          ),
          CupertinoDialogAction(
            child: Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          ),
        ],
      );
    });
    return Future.value(false);
  }
}

class ImageActionSheet extends StatelessWidget {
  ImageActionSheet({@required this.uid});
  final String uid;
  Function(File val) file;

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
            Navigator.of(context).push( // Then push the camera route onto the stack.
              CupertinoPageRoute(
                fullscreenDialog: true, // loads form from bottom
                builder: (context) {
                  return ImageCapture(source: ImageSource.camera, uid: this.uid);
                }
              ),
            );
          }
        ),
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
            Navigator.of(context).push( // Then push the gallery route onto the stack.
              CupertinoPageRoute(
                fullscreenDialog: true, // loads from bottom
                builder: (context) {
                  return ImageCapture(source: ImageSource.gallery, uid: this.uid);
                }
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Widget to capture and crop the image
class ImageCapture extends StatefulWidget {
  ImageCapture({@required this.source, @required this.uid});
  final String uid;
  final ImageSource source;

  createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  /// Active image file
  File _imageFile;

  @override
  void initState() {
    super.initState();
    _pickImage(widget.source);
  }

  /// Select an image via gallery or camera
  void _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(
      source: source,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 80
    );
    setState(() {
      _imageFile = selected;
    });
    /// Cropper plugin
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      maxWidth: 100,
      maxHeight: 100,
      aspectRatio: CropAspectRatio(ratioX: 20, ratioY: 20),
      cropStyle: CropStyle.circle,
      // compressQuality: 50
    );
    setState(() {
      _imageFile = cropped;
    });
  }

  /// Remove image
  // void _clear() {
  //   setState(() => _imageFile = null);
  // }

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
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                if (_imageFile == null) ...[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: CupertinoActivityIndicator(animating: true),
                  )
                ],
                if (_imageFile != null) ...[
                  Image.file(_imageFile),
                  Uploader(uid: widget.uid, file: _imageFile)
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  Uploader({@required this.uid, @required this.file});
  
  final String uid;
  final File file;
  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://suspension-pro.appspot.com/');

  final db = DatabaseService();
  StorageUploadTask _uploadTask;
  StorageReference storageRef;

  /// Starts an upload task
  Future<void> _uploadToFirebase() async {
    final String filePath = 'userImages/${widget.uid}/profile.jpg';
    setState(() {
      storageRef = _storage.ref().child(filePath);
      _uploadTask = storageRef.putFile(widget.file);
      if (_uploadTask.isComplete) {
        _userCollectionUpload(_uploadTask.lastSnapshot.ref);
      }
    });
  }

  Future<void> _userCollectionUpload(ref) async {
    final String downloadUrl = await ref.getDownloadURL();
    /// Set the profilePic path in the user collection, which will trigger 
    /// a change in the stream and the Profile Avatar should be refreshed.
    db.setProfilePic(widget.uid, downloadUrl);
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      /// Manage the task state and event subscription with a StreamBuilder
      return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;

          double progressPercent = event != null
              ? event.bytesTransferred / event.totalByteCount
              : 0;
         
          return Column(
            children: [
              if (_uploadTask.isInProgress) ...[
                // Progress bar
                LinearProgressIndicator(value: progressPercent),
                Text(
                  '${(progressPercent * 100).toStringAsFixed(2)} % '
                ),

                if (_uploadTask.isPaused)
                  FlatButton(
                    child: Icon(Icons.play_arrow),
                    onPressed: _uploadTask.resume,
                  ),

                if (_uploadTask.isInProgress)
                  FlatButton(
                    child: Icon(Icons.pause),
                    onPressed: _uploadTask.pause,
                  ),
              ],
              AnimatedContainer(
                padding: EdgeInsets.all(16),
                child: Text('Upload complete!', style: TextStyle(fontSize: 20)),
                duration: Duration(milliseconds: 500),
              ),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: Text('close'),
                onPressed: () {
                  _userCollectionUpload(_uploadTask.lastSnapshot.ref);
                  Navigator.pop(context);
                }
              ),
            ],
          );
        }
      );
    }
    // Allows user to decide when to start the upload
    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1.5,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 60),
              child: CupertinoButton(
                child: Text('Upload'),
                color: CupertinoColors.activeBlue,
                // icon: Icon(Icons.cloud_upload),
                onPressed: _uploadToFirebase,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: CupertinoButton(
                child: Text('Cancel'),
                color: CupertinoColors.destructiveRed,
                // icon: Icon(Icons.cloud_upload),
                onPressed: Navigator.of(context).pop,
              ),
            ),
          ],
      ),
    );
  }
}