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
  Settings({this.bike});

  final String bike;
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final db = DatabaseService();
  final AuthService auth = AuthService();
  String selected;
  bool _expanded;

  @override
  void initState() {
    super.initState();
  }

  Widget _getBikes(uid, bikes, context){
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: bikes.length,
      itemBuilder: (context, index) {
        Bike $bike = bikes[index];
        var fork = $bike.fork ?? null;
        var shock = $bike.shock ?? null;
        return Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
          margin: EdgeInsets.only(bottom: 10),
          child: Dismissible(
            background: ListTile(
              trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => setState(() {
              bikes.removeAt(index);
              db.deleteBike(uid, $bike.id);
            }),
            key: PageStorageKey($bike),
            child: ExpansionTile(
              initiallyExpanded: selected == $bike.id ? true : false,
              key: PageStorageKey($bike),
              title: Text($bike.id, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              children: <Widget>[
                fork != null ? 
                  GestureDetector(
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(2),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white60,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/fox36-black.png')
                      ),
                      title: Text(fork["year"].toString() + ' ' + fork["brand"] + ' ' + fork["model"], style: TextStyle(color: Colors.white)),
                      subtitle: Text(fork["travel"].toString() + 'mm / ' + fork["damper"] + ' / ' + fork["offset"].toString() + 'mm / ' + fork["wheelsize"].toString() + '"', style: TextStyle(color: Colors.white)),
                    ),
                    onTap: () async {
                      /// Await the bike return value from the fork form back button, 
                      var bike = await Navigator.push(context,
                        CupertinoPageRoute(
                          fullscreenDialog: true,
                          builder: (context) {
                            return CupertinoPageScaffold(
                              resizeToAvoidBottomInset: true,
                              navigationBar: CupertinoNavigationBar(
                                /// This should allow me to pass the $bike argument back to the Setting
                                /// screen so we can expand the appropriate expansion panel.
                                leading: CupertinoButton(child: BackButtonIcon(),
                                  onPressed:() => Navigator.pop(context, $bike.id)
                                ),
                                middle: Text(fork != null ? fork['brand'] + ' ' + fork['model'] : 'Add fork'),
                              ),
                              child: ForkForm(uid: uid, bike: $bike.id, fork: fork),
                            );
                          }
                        ),
                      );
                      setState(() {
                        selected = "$bike";
                      });
                    }
                  )
                  : ListTile(
                      leading: Image.asset('assets/fox36-black.png', height: 35),
                      title: Text('No fork info'),
                    ),
                    // If shock data exists populate info and link to settings.
                    shock != null ?
                    GestureDetector(
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(2),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            shape: BoxShape.circle,
                          ),
                        child: Image.asset('assets/fox-dpx2.png'),
                        ),
                        title: Text(shock["year"].toString() + ' ' + shock["brand"] + ' ' + shock["model"], style: TextStyle(color: Colors.white)),
                        subtitle: Text(shock["stroke"] ?? '', style: TextStyle(color: Colors.white)),
                      ),
                      onTap: () async {
                        /// Await the bike return value from the shock form back button.
                        var bike = await Navigator.push(context,
                          CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (context) {
                              return CupertinoPageScaffold(
                                resizeToAvoidBottomInset: true,
                                navigationBar: CupertinoNavigationBar(
                                  /// This should allow me to pass the $bike argument back to the Setting
                                  /// screen so we can expand the appropriate expansion panel.
                                  leading: CupertinoButton(child: BackButtonIcon(),
                                    onPressed:() => Navigator.pop(context, $bike.id)
                                  ),
                                  middle: Text($bike != null ? shock['brand'] + ' ' + shock['model'] : ''),
                                ),
                                child: ShockForm(uid: uid, bike: $bike.id, shock: shock),
                              );
                            },
                          )
                        );
                        setState(() {
                          selected = "$bike";
                        });
                      }
                    ) 
                  : ListTile(
                    leading: Container(
                        padding: EdgeInsets.all(2),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white60,
                          shape: BoxShape.circle,
                        ),
                      child: Image.asset('assets/fox-dpx2.png'),
                      ),
                      title: Text('No shock info'),
                    ),
                    GestureDetector(
                      child: ListTile(
                        leading: Icon(CupertinoIcons.settings, color: Colors.white60),
                        title: Text('Suspension Settings', style: TextStyle(color: Colors.white)),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white30),
                      ),
                      onTap: () async {
                        var bike = await Navigator.of(context).push(
                          CupertinoPageRoute(builder: (context) {
                            // Return the shock detail form screen here.
                            return SettingsList(bike: $bike);
                          })
                        );
                        setState(() {
                          selected = "$bike";
                        });
                      }
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
    double height = MediaQuery.of(context).size.height;
    var user = Provider.of<FirebaseUser>(context, listen: false);
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
              padding: EdgeInsets.only(bottom: 0),
              child: Icon(Icons.power_settings_new),
              onPressed: () => _requestPop(context)
            ),
          ),
          child: AnimatedContainer(
            key: Key('settings'),
            duration: Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            height: height,
            padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              image: DecorationImage(
                image: AssetImage("assets/roost.jpg"),
                fit: BoxFit.contain,
                alignment: Alignment.topLeft
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Card(
                    color: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                  child: Column(
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
                      SizedBox(height: 20),
                      // Expanded(child: Container())
                    ],
                  ),
                  ),
                ],
              ),
            ),
          ),
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