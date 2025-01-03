import 'dart:async';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:suspension_pro/features/roadmap/app_roadmap.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'package:suspension_pro/utilities/helpers.dart';
import 'package:suspension_pro/features/profile/profile_pic.dart';
import 'package:suspension_pro/features/profile/profile_username_form.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import 'package:flutter/cupertino.dart';
import '../../models/user.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
        stream: db.streamUser(),
        builder: (context, snapshot) {
          var myUser = snapshot.data;
          if (myUser == null) {
            return Center(child: CupertinoActivityIndicator(animating: true));
          }

          return CupertinoPageScaffold(
            resizeToAvoidBottomInset: true,
            navigationBar: CupertinoNavigationBar(
              leading: SizedBox(
                width: 60,
                child: ConnectivityWidgetWrapper(
                  alignment: Alignment.centerLeft,
                  offlineWidget:
                      Icon(Icons.wifi_off, size: 24, color: Colors.red),
                ),
              ),
              middle: Text(myUser.username ?? UserSingleton().email),
              trailing: CupertinoButton(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Icon(Icons.power_settings_new),
                  onPressed: () => _signOut(context)),
            ),
            child: Material(
              color: Colors.white,
              child: ListView(
                children: [
                  Row(
                    children: [
                      ProfilePic(user: myUser),
                      ProfileNameForm(user: myUser),
                    ],
                  ),
                  // UserPoints(user: myUser),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Divider(),
                  ),
                  // ListTile(
                  //   title: Text('Points Guide'),
                  //   trailing: Icon(Icons.arrow_forward_ios),
                  //   onTap: () => null,
                  // ),

                  ListTile(
                    title: Text('App Roadmap'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AppRoadmap())),
                  ),
                  ListTile(
                    title: Text('Privacy Policy'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => loadURL(
                        'https://vibesoftware.io/privacy/suspension_pro'),
                  ),
                  ListTile(
                    title: Text('Terms & Conditions'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () =>
                        loadURL('https://vibesoftware.io/terms/suspension_pro'),
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
