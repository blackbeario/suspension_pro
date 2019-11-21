// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import './models/user.dart';

class Settings extends StatelessWidget {
  final db = DatabaseService();
  final AuthService auth = AuthService();

  // Custom widget for user bikes display.
  Widget _getBikes(List<dynamic> bikes){
    return Column(
      children: bikes.map((bike) {
        return GestureDetector(
          child: Material(
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(40, 0, 40, 0),
              leading: Icon(Icons.check_circle_outline, color: Colors.green[300]),
              title: Text(bike["bike"]),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
        );
      }).toList()
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
            middle: Text('Settings'),
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
                myUser.bikes != null ? _getBikes(myUser.bikes) : 
                  ListTile(
                    title: Text(
                      'Add some bikes!',
                      textAlign: TextAlign.center,
                    ),
                  ),
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

