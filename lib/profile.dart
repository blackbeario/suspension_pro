// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import './models/user.dart';
import './settings_list.dart';

class Profile extends StatelessWidget {
  final db = DatabaseService();
  final AuthService auth = AuthService();

  // Custom widget for user bikes display.
  Widget _getBikes(List<dynamic> bikes, context){
    return ListView(
      shrinkWrap: true,
      children: bikes.map((bike) {
        return ExpansionTile(
          initiallyExpanded: false,
          key: PageStorageKey<String>(bike["bike"]),
          title: Text(bike["bike"]),
          children: <Widget>[
            // If fork data exists populate info and link to settings.
            bike["fork"] != null ? 
              GestureDetector(
                child: ListTile(
                  leading: Image.asset('fork.png', width: 35, height: 35, color: Colors.grey[600]),
                  title: Text(bike["fork"]["year"].toString() + ' ' + bike["fork"]["brand"] + ' ' + bike["fork"]["model"]),
                  subtitle: Text(bike["fork"]["travel"].toString() + 'mm / ' + bike["fork"]["damper"] + ' / ' + bike["fork"]["offset"].toString() + 'mm / ' + bike["fork"]["wheelsize"].toString() + '"'),
                  // trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) {
                    return Settings();
                  }));
                }) 
            : ListTile(
                leading: Image.asset('fork.png', width: 35, height: 35, color: Colors.grey[300]),
                title: Text('No fork info'),
              ),
            // If shock data exists populate info and link to settings.
            bike["shock"] != null ?
              ListTile(
                leading: Image.asset('shock.png', width: 35, height: 35),
                title: Text(bike["shock"]["year"].toString() + ' ' + bike["shock"]["brand"] + ' ' + bike["shock"]["model"]),
                subtitle: Text(bike["shock"]["stroke"]),
              ) : ListTile(
                leading: Image.asset('shock.png', width: 35, height: 35, color: Colors.grey[300]),
                title: Text('No shock info'),
              ),
          ],
        );
      }).toList(),
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
            middle: Text('Profile'),
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
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(myUser.username),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(myUser.role),
                ),
                myUser.bikes != null ? _getBikes(myUser.bikes, context) : 
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

