import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_list.dart';
import 'shock_form.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import './models/user.dart';
import 'bikeform.dart';
import 'fork_form.dart';

class Settings extends StatefulWidget {
  Settings({required this.user, this.bike});

  final AppUser user;
  final String? bike;
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final db = DatabaseService();
  late Bike selected;

  @override
  void initState() {
    super.initState();
  }

  Widget _getBikes(uid, bikes, context) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: bikes.length,
      itemBuilder: (context, index) {
        Bike $bike = bikes[index];
        var fork = $bike.fork;
        var shock = $bike.shock;
        selected = bikes[0];
        return Dismissible(
          background: ListTile(
            trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => setState(() {
            bikes.removeAt(index);
            db.deleteBike(uid, $bike.id!);
          }),
          key: PageStorageKey($bike),
          child: ExpansionTile(
            initiallyExpanded: selected == $bike ? true : false,
            key: PageStorageKey($bike),
            title: Text($bike.id!,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            children: <Widget>[
              fork != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                          Container(
                              padding: EdgeInsets.all(2),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                shape: BoxShape.circle,
                              ),
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
                                    style: TextStyle(color: Colors.black87)),
                                subtitle: Text(
                                    fork["travel"].toString() +
                                        'mm / ' +
                                        fork["damper"] +
                                        ' / ' +
                                        fork["offset"].toString() +
                                        'mm / ' +
                                        fork["wheelsize"].toString() +
                                        '"',
                                    style: TextStyle(color: Colors.black54)),
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
                                                      Navigator.pop(
                                                          context, $bike.id)),
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
                              _confirmDelete(context, uid, $bike.id, 'fork');
                            },
                          ),
                        ])
                  : OutlinedButton(
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
                                        onPressed: () =>
                                            Navigator.pop(context, $bike.id)),
                                    middle: Text('Add Fork'),
                                  ),
                                  child: ForkForm(
                                      uid: uid, bikeId: $bike.id, fork: fork),
                                );
                              },
                            ));
                        setState(() {
                          selected = $bike;
                        });
                      },
                    ),
              // If shock data exists populate info and link to settings.
              shock != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            padding: EdgeInsets.all(4),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              shape: BoxShape.circle,
                            ),
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
                                          navigationBar: CupertinoNavigationBar(
                                            /// This should allow me to pass the $bike argument back to the Setting
                                            /// screen so we can expand the appropriate expansion panel.
                                            leading: CupertinoButton(
                                                child: BackButtonIcon(),
                                                onPressed: () => Navigator.pop(
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
                    )
                  : OutlinedButton(
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
                                        onPressed: () =>
                                            Navigator.pop(context, $bike.id)),
                                    middle: Text('Add Shock'),
                                  ),
                                  child: ShockForm(
                                      uid: uid, bike: $bike.id, shock: shock),
                                );
                              },
                            ));
                        setState(() {
                          selected = $bike;
                        });
                      },
                    ),
              GestureDetector(
                  child: ListTile(
                    leading:
                        Icon(CupertinoIcons.settings, color: Colors.black54),
                    title: Text('Suspension Settings',
                        style: TextStyle(color: Colors.black87)),
                    trailing:
                        Icon(Icons.arrow_forward_ios, color: Colors.black38),
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<AppUser?>(
        stream: authService.user,
        builder: (context, snapshot) {
          var myUser = snapshot.data;
          if (myUser == null) {
            return Center(
              child: CupertinoActivityIndicator(animating: true),
            );
          }
          return CupertinoPageScaffold(
            resizeToAvoidBottomInset: true,
            navigationBar: CupertinoNavigationBar(
              middle: Text('Settings'),
              trailing: CupertinoButton(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Icon(Icons.power_settings_new),
                  onPressed: () => _signOut(context, authService)),
            ),
            child: AnimatedContainer(
              key: Key('settings'),
              duration: Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              height: height,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                image: DecorationImage(
                    image: AssetImage("assets/cupcake.jpg"),
                    fit: BoxFit.none,
                    alignment: Alignment.topCenter),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Card(
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
                              stream: db.streamBikes(myUser.id),
                              builder: (context, snapshot) {
                                var bikes = snapshot.data;
                                if (bikes == null) {
                                  return Center(
                                      child: CupertinoActivityIndicator(
                                          animating: true));
                                }
                                // return Text('bike list');
                                return _getBikes(myUser.id, bikes, context);
                              }),
                          SizedBox(height: 20),
                          CupertinoButton(
                            color: CupertinoColors.activeBlue,
                            child: Text('Add Bike'),
                            onPressed: () => Navigator.of(context).push(
                                CupertinoPageRoute(
                                    fullscreenDialog:
                                        true, // loads form from bottom
                                    builder: (context) {
                                      // We need to return the shock detail screen here.
                                      return BikeForm(uid: myUser.id);
                                    })),
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
        });
  }

  Future<bool> _confirmDelete(
      BuildContext context, uid, bikeId, String component) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Delete $component'),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Okay'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, 'Discard');
                    db.deleteField(uid, bikeId, component);
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
