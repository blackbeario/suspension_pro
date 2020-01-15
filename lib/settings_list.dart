// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suspension_pro/setting_detail.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import './models/user.dart';
import 'models/setting.dart';

class SettingsList extends StatefulWidget {
  SettingsList({@required this.bike});
  final bike;

  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  final db = DatabaseService();

  final AuthService auth = AuthService();

    Widget _getSettings(uid, bike, settings, context){
      return ListView.builder(
        shrinkWrap: true,
        itemCount: settings.length,
        itemBuilder: (context, index) {
          var fork = settings[index].fork ?? null;
          var shock = settings[index].shock ?? null;
          return Dismissible(
            background: ListTile(
              trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
            ),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) => setState(() {
              db.deleteSetting(uid, bike.id, settings[index].id);
              settings.removeAt(index);
            }),
            key: PageStorageKey(settings[index]),
            child: GestureDetector(
              key: PageStorageKey(settings[index]),
              child: ListTile(
                title: Text(settings[index].id),
                subtitle: Text(this.widget.bike.id),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    fullscreenDialog: true, // loads form from bottom
                    builder: (context) {
                    // Return the settings detail form screen. 
                    return SettingDetails(
                      uid: uid, bike: this.widget.bike, setting: settings[index].id, 
                      fork: fork, shock: shock
                    );
                  })
                );
              }
            ),
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    if (user == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
        )
      );
    }
    return StreamBuilder<User>(
      stream: db.streamUser(user.uid),
      builder: (context, snapshot) {
        var myUser = snapshot.data;
        if (myUser == null) {
          return Center(
            child: Text('Loading...',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
          );
        }
        return CupertinoPageScaffold(
          resizeToAvoidBottomInset: true,
          navigationBar: CupertinoNavigationBar(
            middle: Text('Settings / ' + this.widget.bike.id),
            trailing: CupertinoButton(
              child: Icon(Icons.power_settings_new),
              onPressed: () => _requestPop(context)
            ),
          ),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                StreamBuilder<List<Setting>>(
                  stream: db.streamSettings(user.uid, this.widget.bike.id.toString()),
                  builder: (context, snapshot) {
                    var settings = snapshot.data;
                    // var fork = settings[index].fork ?? null;
                    // var shock = settings[index].shock ?? null;
                    if (settings == null) {
                      return Center(
                        child: Text('Loading...',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
                      );
                    }
                    if (snapshot.error != null) {
                      return Center(
                        child: Text('Error...',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
                      );
                    }
                    return _getSettings(user.uid, this.widget.bike, settings, context);
                  }
                ),
                CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  child: Text('Add Setting'),
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      fullscreenDialog: true, // loads form from bottom
                      builder: (context) {
                      // We need to return the shock detail screen here.
                      return SettingDetails(uid: user.uid, bike: this.widget.bike);
                    })
                  ),
                ),
                Expanded(child: Container())
              ],
            ),
          )
        );
      }
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
    return new Future.value(false);
  }
}

