import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suspension_pro/features/bikes/firebase_bikes_list.dart';
import 'package:suspension_pro/features/bikes/hive_bikes_list.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'package:suspension_pro/services/auth_service.dart';
import 'package:suspension_pro/services/db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:suspension_pro/features/forms/bikeform.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BikesListScreen extends StatefulWidget {
  BikesListScreen({this.bike});

  final String? bike;

  @override
  State<BikesListScreen> createState() => _BikesListScreenState();
}

class _BikesListScreenState extends State<BikesListScreen> {
  final db = DatabaseService();
  final bool hasProAccount = UserSingleton().proAccount;
  final FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'gs://suspension-pro.appspot.com/');

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        leading: SizedBox(
          width: 60,
          child: ConnectivityWidgetWrapper(
            alignment: Alignment.centerLeft,
            offlineWidget: Icon(Icons.wifi_off, size: 24, color: Colors.red),
          ),
        ),
        middle: Text('Bikes & Settings'),
        trailing: CupertinoButton(
            padding: EdgeInsets.only(bottom: 0),
            child: Icon(Icons.power_settings_new),
            onPressed: () => _signOut(context)),
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
              image: AssetImage("assets/cupcake.jpg"), fit: BoxFit.none, alignment: Alignment.topCenter),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: (Radius.circular(16)), topRight: (Radius.circular(16)))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ConnectivityWidgetWrapper(
                    offlineWidget: HiveBikesList(),
                    child: hasProAccount ? FirebaseBikesList() : HiveBikesList(),
                    stacked: false,
                  ),
                  // _connectivityWidget(),
                  SizedBox(height: 30),
                  CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    child: Text('Add Bike'),
                    onPressed: () => Navigator.of(context)
                        .push(CupertinoPageRoute(fullscreenDialog: true, builder: (context) => BikeForm())),
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

  Future<bool> _signOut(BuildContext context) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog.adaptive(
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
                onPressed: () => Navigator.pop(context, 'Cancel'),
              ),
            ],
          );
        });
    return Future.value(false);
  }
}
