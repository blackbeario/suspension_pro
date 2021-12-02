import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/bike.dart';
import 'settings_list.dart';
import 'shock_form.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import './models/user.dart';
import 'bikeform.dart';
import 'fork_form.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  Settings({required this.user, this.bike});

  final AppUser user;
  final String? bike;
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final db = DatabaseService();
  late Bike selected = Bike();
  FirebaseStorage storage =
      FirebaseStorage.instanceFor(bucket: 'gs://suspension-pro.appspot.com/');
  late String downloadUrl = '';
  File? _imageFile;
  var imagePicker;

  @override
  void initState() {
    super.initState();
  }

  /// Get from gallery
  _getFromGallery(bikeid) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    _cropImage(bikeid, pickedFile!.path);
  }

  /// Crop Image
  _cropImage(bikeid, filePath) async {
    File? croppedImage = await ImageCropper.cropImage(
        cropStyle: CropStyle.circle, sourcePath: filePath, compressQuality: 50);
    if (croppedImage != null) {
      _imageFile = croppedImage;
      _uploadToFirebase(widget.user.id, bikeid, _imageFile!);
      setState(() {});
    }
  }

  _uploadToFirebase(uid, bikeid, File imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
        storage.ref().child('userImages/$uid/bikes/$bikeid/bike.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    uploadTask.whenComplete(() async {
      downloadUrl = await ref.getDownloadURL();
      db.setBikePic(uid, bikeid, downloadUrl);
    }).catchError((onError) {
      print(onError);
    });
  }

  Widget _getBikes(uid, bikes, context) {
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final bike = bikes.removeAt(oldIndex);
          bikes.insert(newIndex, bike);
          for (Bike bike in bikes) {
            bike.index = bikes.indexOf(bike);
            db.reorderBike(uid, bike.id!, bike.index!);
          }
        });
      },
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: bikes.length,
      itemBuilder: (context, index) {
        Bike $bike = bikes[index];
        var fork = $bike.fork;
        var shock = $bike.shock;
        return Dismissible(
          background: ListTile(
            tileColor: CupertinoColors.destructiveRed.withOpacity(0.125),
            trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss:(direction) async {
            await _confirmDelete(context, uid, $bike.id!, null);
          },
          // onDismissed: (direction) => setState(() {
          //   _confirmDelete(context, uid, $bike.id!, null);
          //   bikes.removeAt(index);
          // }),
          key: ValueKey($bike.id),
          child: Container(
            decoration: index != bikes.length - 1
                ? BoxDecoration(
                    border: new Border(
                        bottom: BorderSide(color: Colors.grey.shade200)))
                : null,
            child: ExpansionTile(
              // backgroundColor: CupertinoColors.extraLightBackgroundGray,
              leading: Container(
                child: $bike.bikePic!.isEmpty
                    ? CupertinoButton(
                        padding: EdgeInsets.only(bottom: 0),
                        child: Icon(Icons.photo_camera),
                        onPressed: () => _getFromGallery($bike.id))
                    : CircleAvatar(
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: $bike.bikePic!,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            placeholder: (context, url) =>
                                Icon(Icons.pedal_bike_sharp),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.photo_camera),
                          ),
                        ),
                      ),
              ),
              // leading: Icon(Icons.menu, color: CupertinoColors.inactiveGray.withOpacity(0.5)),
              initiallyExpanded: selected.id == $bike.id ? true : false,
              key: PageStorageKey($bike),
              title: Text($bike.id!, style: TextStyle(fontSize: 18)),
              children: <Widget>[
                fork != null
                    ? Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.extraLightBackgroundGray
                              .withOpacity(0.5),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(2),
                                  width: 35,
                                  height: 35,
                                  // decoration: BoxDecoration(
                                  //   color: Colors.white,
                                  //   shape: BoxShape.circle,
                                  // ),
                                  child: Image.asset('assets/fork.png')),
                              Container(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                                width: 200,
                                child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(
                                        fork["year"].toString() +
                                            ' ' +
                                            fork["brand"] +
                                            ' ' +
                                            fork["model"],
                                        style:
                                            TextStyle(color: Colors.black87)),
                                    subtitle: Text(
                                        fork["travel"].toString() +
                                            'mm / ' +
                                            fork["damper"] +
                                            ' / ' +
                                            fork["offset"].toString() +
                                            'mm / ' +
                                            fork["wheelsize"].toString() +
                                            '"',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                    onTap: () async {
                                      /// Await the bike return value from the fork form back button,
                                      await Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            fullscreenDialog: true,
                                            builder: (context) {
                                              return CupertinoPageScaffold(
                                                resizeToAvoidBottomInset: true,
                                                navigationBar:
                                                    CupertinoNavigationBar(
                                                  /// This should allow me to pass the $bike argument back to the Setting
                                                  /// screen so we can expand the appropriate expansion panel.
                                                  leading: CupertinoButton(
                                                      child: BackButtonIcon(),
                                                      onPressed: () =>
                                                          Navigator.pop(context,
                                                              $bike.id)),
                                                  middle: Text(fork != null
                                                      ? fork['brand'] +
                                                          ' ' +
                                                          fork['model']
                                                      : 'Add fork'),
                                                ),
                                                child: ForkForm(
                                                    uid: uid,
                                                    bikeId: $bike.id,
                                                    fork: fork),
                                              );
                                            }),
                                      );
                                      setState(() {
                                        selected = $bike;
                                      });
                                    }),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline_sharp,
                                    size: 16, color: Colors.black38),
                                onPressed: () {
                                  _confirmDelete(
                                      context, uid, $bike.id, 'fork');
                                },
                              ),
                            ]),
                      )
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: CupertinoColors.extraLightBackgroundGray
                              .withOpacity(0.5),
                        ),
                        child: OutlinedButton(
                          style: ElevatedButton.styleFrom(
                            alignment: Alignment.center,
                            fixedSize: Size(280, 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            primary: CupertinoColors.extraLightBackgroundGray,
                            onPrimary: CupertinoColors.black,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add),
                              Text(' Add Fork'),
                            ],
                          ),
                          onPressed: () async {
                            /// Await the bike return value from the shock form back button.
                            var bike = await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) {
                                    return CupertinoPageScaffold(
                                      resizeToAvoidBottomInset: true,
                                      navigationBar: CupertinoNavigationBar(
                                        /// This should allow me to pass the $bike argument back to the Setting
                                        /// screen so we can expand the appropriate expansion panel.
                                        leading: CupertinoButton(
                                            child: BackButtonIcon(),
                                            onPressed: () => Navigator.pop(
                                                context, $bike.id)),
                                        middle: Text('Add Fork'),
                                      ),
                                      child: ForkForm(
                                          uid: uid,
                                          bikeId: $bike.id,
                                          fork: fork),
                                    );
                                  },
                                ));
                            setState(() {
                              selected = $bike;
                            });
                          },
                        ),
                      ),
                // If shock data exists populate info and link to settings.
                shock != null
                    ? Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.extraLightBackgroundGray
                              .withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                                padding: EdgeInsets.all(4),
                                width: 35,
                                height: 35,
                                // decoration: BoxDecoration(
                                //   color: Colors.white,
                                //   shape: BoxShape.circle,
                                // ),
                                child: shock != null
                                    ? Image.asset('assets/shock.png')
                                    : null),
                            Container(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                              width: 200,
                              child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: Text(
                                      shock["year"].toString() +
                                          ' ' +
                                          shock["brand"] +
                                          ' ' +
                                          shock["model"],
                                      style: TextStyle(color: Colors.black87)),
                                  subtitle: Text(shock["stroke"] ?? '',
                                      style: TextStyle(color: Colors.black54)),
                                  onTap: () async {
                                    /// Await the bike return value from the shock form back button.
                                    var bike = await Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          fullscreenDialog: true,
                                          builder: (context) {
                                            return CupertinoPageScaffold(
                                              resizeToAvoidBottomInset: true,
                                              navigationBar:
                                                  CupertinoNavigationBar(
                                                /// This should allow me to pass the $bike argument back to the Setting
                                                /// screen so we can expand the appropriate expansion panel.
                                                leading: CupertinoButton(
                                                    child: BackButtonIcon(),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, $bike.id)),
                                                middle: Text($bike != null
                                                    ? shock['brand'] +
                                                        ' ' +
                                                        shock['model']
                                                    : ''),
                                              ),
                                              child: ShockForm(
                                                  uid: uid,
                                                  bike: $bike.id,
                                                  shock: shock),
                                            );
                                          },
                                        ));
                                    setState(() {
                                      selected = $bike;
                                    });
                                  }),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline_sharp,
                                  size: 16, color: Colors.black38),
                              onPressed: () {
                                _confirmDelete(context, uid, $bike.id, 'shock');
                              },
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: CupertinoColors.extraLightBackgroundGray
                              .withOpacity(0.5),
                        ),
                        child: OutlinedButton(
                          style: ElevatedButton.styleFrom(
                            alignment: Alignment.center,
                            // fixedSize: Size(100, 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            primary: CupertinoColors.extraLightBackgroundGray,
                            onPrimary: CupertinoColors.black,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add),
                              Text(' Add Shock'),
                            ],
                          ),
                          onPressed: () async {
                            /// Await the bike return value from the shock form back button.
                            await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) {
                                    return CupertinoPageScaffold(
                                      resizeToAvoidBottomInset: true,
                                      navigationBar: CupertinoNavigationBar(
                                        /// This should allow me to pass the $bike argument back to the Setting
                                        /// screen so we can expand the appropriate expansion panel.
                                        leading: CupertinoButton(
                                            child: BackButtonIcon(),
                                            onPressed: () => Navigator.pop(
                                                context, $bike.id)),
                                        middle: Text('Add Shock'),
                                      ),
                                      child: ShockForm(
                                          uid: uid,
                                          bike: $bike.id,
                                          shock: shock),
                                    );
                                  },
                                ));
                            setState(() {
                              selected = $bike;
                            });
                          },
                        ),
                      ),
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.extraLightBackgroundGray
                        .withOpacity(0.5),
                  ),
                  child: GestureDetector(
                      child: ListTile(
                        leading: Icon(CupertinoIcons.settings,
                            color: Colors.black54),
                        title: Text('Ride Settings',
                            style: TextStyle(color: Colors.black87)),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Colors.black38),
                      ),
                      onTap: () async {
                        await Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (context) {
                          // Return the shock detail form screen here.
                          return SettingsList(bike: $bike);
                        }));
                        setState(() {
                          selected = $bike;
                        });
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Bikes & Settings'),
        trailing: CupertinoButton(
            padding: EdgeInsets.only(bottom: 0),
            child: Icon(Icons.power_settings_new),
            onPressed: () => _signOut(context, authService)),
      ),
      child: Container(
        key: ValueKey('settings'),
        // height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.transparent,
              Colors.transparent,
              CupertinoColors.extraLightBackgroundGray.withOpacity(0.25)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0, 0.7, 1],
          ),
          image: DecorationImage(
              image: AssetImage("assets/cupcake.jpg"),
              fit: BoxFit.none,
              alignment: Alignment.topCenter),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: (Radius.circular(16)),
                      topRight: (Radius.circular(16)))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder<List<Bike>>(
                      stream: db.streamBikes(widget.user.id),
                      builder: (context, snapshot) {
                        var bikes = snapshot.data;
                        if (!snapshot.hasData)
                          return Center(
                              child:
                                  CupertinoActivityIndicator(animating: true));
                        return _getBikes(widget.user.id, bikes, context);
                      }),
                  SizedBox(height: 20),
                  CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    child: Text('Add Bike'),
                    onPressed: () =>
                        Navigator.of(context).push(CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (context) {
                              return BikeForm(uid: widget.user.id);
                            })),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
      BuildContext context, uid, bikeId, String? component) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: component != null
                ? Text('Delete $component')
                : Text('Delete $bikeId'),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Okay'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, true);
                    if (component == null) db.deleteBike(uid, bikeId);
                    if (component != null)
                      db.deleteField(uid, bikeId, component);
                  }),
              CupertinoDialogAction(
                child: Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          );
        });
    return new Future.value(false);
  }

  Future<bool> _signOut(BuildContext context, authService) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Signout'),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Okay'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, 'Discard');
                    authService.signOut();
                  }),
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
    return new Future.value(false);
  }
}
