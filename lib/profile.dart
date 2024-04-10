import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import './models/user.dart';
import 'imageActionSheet.dart';

class Profile extends StatefulWidget {
  Profile({Key? key, required this.user}) : super(key: key);
  final AppUser user;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final db = DatabaseService();
  String? profilePic;
  late String role;
  bool usernameUpdated = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<bool> _updateUser(uid, BuildContext context) {
    db.updateUser(
        widget.user.id, _usernameController.text, widget.user.email!, role);
    return Future.value(false);
  }

  void _toggle() {
    setState(() {
      usernameUpdated = !usernameUpdated;
    });
  }

  _setUsername(value) {
    _usernameController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
        stream: db.streamUser(widget.user.id),
        builder: (context, snapshot) {
          var myUser = snapshot.data;
          if (myUser == null) {
            return Center(child: CupertinoActivityIndicator(animating: true));
          }
          if (_usernameController.text == '') _setUsername(myUser.username!);
          role = myUser.role!;
          return CupertinoPageScaffold(
            resizeToAvoidBottomInset: true,
            navigationBar: CupertinoNavigationBar(
              middle: Text(myUser.username ?? widget.user.email!),
              trailing: CupertinoButton(
                  child: Icon(Icons.power_settings_new),
                  onPressed: () => _signOut(context)),
            ),
            child: Material(
              child: ListView(
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
                                  radius: 102.5,
                                  child: ClipOval(
                                    child: myUser.profilePic != '' &&
                                            myUser.profilePic != null
                                        ? CachedNetworkImage(
                                            imageUrl: myUser.profilePic!,
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(
                                                    animating: true),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Image.asset(
                                                    'assets/genericUserPic.png'),
                                          )
                                        : Icon(Icons.photo_camera),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => showCupertinoModalPopup(
                        useRootNavigator: true,
                        context: context,
                        builder: (context) =>
                            ImageActionSheet(uid: widget.user.id)),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextFormField(
                              autofocus: false,
                              validator: (_usernameController) {
                                if (_usernameController == null ||
                                    _usernameController.isEmpty)
                                  return 'Please add a username';
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                _toggle();
                              },
                              decoration: InputDecoration(
                                icon: Icon(Icons.person,
                                    size: 28, color: Colors.blue),
                                isDense: true,
                                helperText:
                                    'Feel free to change this to whatever you like. \nYour email address will not change, and you \ndon\'t have to worry about other usernames.',
                                filled: true,
                                hoverColor: Colors.blue.shade100,
                                border: OutlineInputBorder(),
                                hintText: 'username',
                              ),
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[700]),
                              controller: _usernameController,
                              keyboardType: TextInputType.emailAddress),
                        ),
                        ListTile(
                          leading: Icon(Icons.stars, color: Colors.blue),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Level: ' + role,
                                  style: TextStyle(color: Colors.black87)),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text(myUser.points.toString() + 'pts',
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                                'Share settings with others to raise your skill level! Move up from newbie => Pro simply by sharing your suspension settings!',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        SizedBox(height: 30),
                        CupertinoButton(
                            disabledColor: CupertinoColors.inactiveGray,
                            color: CupertinoColors.activeBlue,
                            child: Text('Save',
                                style: TextStyle(color: Colors.white)),
                            onPressed: usernameUpdated
                                ? () {
                                    _toggle();
                                    if (_formKey.currentState!.validate()) {
                                      _updateUser(myUser.id, context);
                                    }
                                  }
                                : null),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<bool> _signOut(BuildContext context) {
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
                    context.read<AuthService>().signOut();
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
    return Future.value(false);
  }
}
