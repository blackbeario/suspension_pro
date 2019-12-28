import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suspension_pro/settings_list.dart';
import 'package:suspension_pro/shock_form.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import './models/user.dart';
import 'bikeform.dart';
import 'fork_form.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: bikes.length,
      itemBuilder: (context, index) {
        var $bike = bikes[index];
        var fork = $bike.fork ?? null;
        var shock = $bike.shock ?? null;
        return Dismissible(
          background: ListTile(
            trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
          ),
          direction: DismissDirection.horizontal,
          // onDismissed: _dismissBike(uid, bikes[index]),
          key: PageStorageKey($bike),
          child: ExpansionTile(
            initiallyExpanded: index == 0 ? true : false,
            key: PageStorageKey($bike),
            title: Text($bike.id),
            children: <Widget>[
              fork != null ? 
                GestureDetector(
                  child: ListTile(
                    leading: Image.asset('assets/fox36-black.jpg', height: 40),
                    title: Text(fork["year"].toString() + ' ' + fork["brand"] + ' ' + fork["model"]),
                    subtitle: Text(fork["travel"].toString() + 'mm / ' + fork["damper"] + ' / ' + fork["offset"].toString() + 'mm / ' + fork["wheelsize"].toString() + '"'),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (context) {
                          return CupertinoPageScaffold(
                            resizeToAvoidBottomInset: true,
                            navigationBar: CupertinoNavigationBar(
                              middle: Text(fork != null ? fork['brand'] + ' ' + fork['model'] : 'Add fork'),
                            ),
                            child: ForkForm(uid: uid, bike: $bike.id, fork: fork),
                          );
                        }
                      ),
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
                        CupertinoPageRoute(
                          fullscreenDialog: true,
                          builder: (context) {
                            // var $bike = widget.bike;
                            // var $shock = widget.shock;
                            return CupertinoPageScaffold(
                              resizeToAvoidBottomInset: true,
                              navigationBar: CupertinoNavigationBar(
                                middle: Text($bike != null ? shock['brand'] + ' ' + shock['model'] : ''),
                              ),
                              child: ShockForm(uid: uid, bike: $bike.id, shock: shock),
                            );
                          },
                        )
                      );
                    }
                  ) 
                : ListTile(
                    leading: Image.asset('assets/fox-dpx2.png', height: 35),
                    title: Text('No shock info'),
                  ),
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(CupertinoIcons.settings),
                      title: Text('Suspension Settings'),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) {
                          // Return the shock detail form screen here.
                          return SettingsList(bike: $bike);
                        })
                      );
                    }
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
            middle: Text('Settings'),
            trailing: CupertinoButton(
              child: Icon(Icons.power_settings_new),
              onPressed: () => _requestPop(context)
            ),
          ),
          child: Material(
            child: ListView(
              // reverse: true,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
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
                        CupertinoPageRoute(
                          fullscreenDialog: true, // loads form from bottom
                          builder: (context) {
                          // We need to return the shock detail screen here.
                          return BikeForm(uid: user.uid);
                        })
                      ),
                    ),
                    // Expanded(child: Container())
                  ],
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