import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import './models/user.dart';
import './susp_detail.dart';
import 'bikeform.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final db = DatabaseService();
  final AuthService auth = AuthService();
  List <Map<dynamic, dynamic>>_bikes;

  @override
  void initState() {
    super.initState();
  }
  
  _dismissBike(uid, bike) {
    setState(() {
      _bikes.remove(bike);
      // db.deleteBike(uid, bike);
    });
  }

  Widget _getBikes(uid, bikes, context){
    return ListView.builder(
      reverse: true,
      shrinkWrap: true,
      itemCount: bikes.length,
      itemBuilder: (context, index) {
        var fork = bikes[index].fork ?? null;
        var shock = bikes[index].shock ?? null;
        return Dismissible(
          background: ListTile(
            trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
          ),
          direction: DismissDirection.horizontal,
          // onDismissed: _dismissBike(uid, bikes[index]),
          key: PageStorageKey(bikes[index]),
          child: ExpansionTile(
            initiallyExpanded: false,
            key: PageStorageKey(bikes[index]),
            title: Text(bikes[index].id),
            children: <Widget>[
              // If fork data exists populate info and link to settings.
              fork != null ? 
                GestureDetector(
                  child: ListTile(
                    leading: Image.asset('assets/fox36-black.jpg', height: 40),
                    title: Text(fork["year"].toString() + ' ' + fork["brand"] + ' ' + fork["model"]),
                    subtitle: Text(fork["travel"].toString() + 'mm / ' + fork["damper"] + ' / ' + fork["offset"].toString() + 'mm / ' + fork["wheelsize"].toString() + '"'),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) {
                        // Return the fork detail form screen here. 
                        return SuspensionDetails(uid: uid, bike: bikes[index].id, fork: fork, type: 'fork');
                      })
                    );
                  }
                )
                  : ListTile(
                      leading: Image.asset('assets/fox36-black.jpg', height: 35),
                      title: Text('No fork info'),
                    ),
                    // If shock data exists populate info and link to settings.
                    shock != null ?
                    GestureDetector(
                      child: ListTile(
                        leading: Image.asset('assets/fox-dpx2.png', height: 40),
                        title: Text(shock["year"].toString() + ' ' + shock["brand"] + ' ' + shock["model"]),
                        subtitle: Text(shock["stroke"] ?? ''),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (context) {
                            // Return the shock detail form screen here.
                            return SuspensionDetails(uid: uid, bike: bikes[index].id, shock: shock, type: 'shock');
                          })
                        );
                      }
                    ) 
                  : ListTile(
                      leading: Image.asset('assets/fox-dpx2.png', height: 35),
                      title: Text('No shock info'),
                    ),
                ],
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
            middle: Text(myUser.username),
            trailing: CupertinoButton(
              child: Icon(Icons.power_settings_new),
              onPressed: () => _requestPop(context)
            ),
          ),
          child: Material(
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
                StreamBuilder<List<Bike>>(
                  stream: db.streamBikes(user.uid),
                  builder: (context, snapshot) {
                    var bikes = snapshot.data;
                    if (bikes == null) {
                      return Center(
                        child: Text('Loading...',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
                      );
                    }
                    return _getBikes(user.uid, bikes, context);
                  }
                ),
                SizedBox(height: 20),
                CupertinoButton(
                  color: CupertinoColors.systemFill,
                  child: Text('Add Bike'),
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) {
                      // We need to return the shock detail screen here.
                      return BikeForm(uid: user.uid);
                    })
                  ),
                ),
                // Expanded(child: Container())
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