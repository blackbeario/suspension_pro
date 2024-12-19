import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/models/component.dart';
import 'package:suspension_pro/models/setting.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'setting_detail.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import 'package:flutter/cupertino.dart';

class SettingsList extends StatefulWidget {
  SettingsList({required this.bike});
  final Bike bike;

  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  final db = DatabaseService();
  final String uid = UserSingleton().id;
  
  Widget _getSettings(Bike bike, List<Setting> settings, context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: settings.length,
      itemBuilder: (context, index) {
        Component? fork = settings[index].fork ?? null;
        Component? shock = settings[index].shock ?? null;
        String? frontTire = settings[index].frontTire ?? null;
        String? rearTire = settings[index].rearTire ?? null;
        String? notes = settings[index].notes ?? null;
        return Dismissible(
          background: ListTile(
            tileColor: CupertinoColors.extraLightBackgroundGray.withOpacity(0.5),
            trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
          ),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) => setState(() {
            db.deleteSetting(bike.id, settings[index].id);
            settings.removeAt(index);
          }),
          key: PageStorageKey(settings[index]),
          child: GestureDetector(
              key: PageStorageKey(settings[index]),
              child: ListTile(
                title: Text(settings[index].id),
                subtitle: Text(widget.bike.id),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (context) {
                      // Return the settings detail form screen.
                      return SettingDetails(
                        bike: widget.bike,
                        setting: settings[index].id,
                        fork: fork,
                        shock: shock,
                        frontTire: frontTire,
                        rearTire: rearTire,
                        notes: notes,
                      );
                    }));
              }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        resizeToAvoidBottomInset: true,
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoButton(child: BackButtonIcon(), onPressed: () => Navigator.pop(context, widget.bike.id)),
          middle: Text(widget.bike.id),
          trailing: CupertinoButton(child: Icon(Icons.power_settings_new), onPressed: () => _requestPop(context)),
        ),
        child: Card(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<List<Setting>>(
                  stream: db.streamSettings(widget.bike.id),
                  builder: (context, snapshot) {
                    var settings = snapshot.data;
                    if (settings == null) {
                      return Center(child: CircularProgressIndicator.adaptive());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error...', style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
                      );
                    }
                    return _getSettings(widget.bike, settings, context);
                  }),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: Text('Add Setting'),
                onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (context) {
                      // We need to return the shock detail screen here.
                      return SettingDetails(bike: widget.bike);
                    })),
              ),
              Expanded(child: Container())
            ],
          ),
        ));
  }

  Future<bool> _requestPop(BuildContext context) {
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
    return new Future.value(false);
  }
}
