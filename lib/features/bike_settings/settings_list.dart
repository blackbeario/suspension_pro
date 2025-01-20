import 'package:flutter/material.dart';
import 'package:suspension_pro/features/bike_settings/share_button.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/models/component_setting.dart';
import 'package:suspension_pro/models/fork.dart';
import 'package:suspension_pro/models/setting.dart';
import 'package:suspension_pro/models/shock.dart';
import 'package:suspension_pro/utilities/helpers.dart';
import 'setting_detail.dart';
import 'package:suspension_pro/services/db_service.dart';
import 'package:flutter/cupertino.dart';

class SettingsList extends StatefulWidget {
  SettingsList({required this.bike});
  final Bike bike;

  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  final db = DatabaseService();

  Widget _getSettings(Bike bike, List<Setting> settings, context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: settings.length,
      itemBuilder: (context, index) {
        ComponentSetting? fork = settings[index].fork ?? null;
        ComponentSetting? shock = settings[index].shock ?? null;
        String? frontTire = settings[index].frontTire ?? null;
        String? rearTire = settings[index].rearTire ?? null;
        String? notes = settings[index].notes ?? null;
        Fork? $fork = bike.fork ?? null;
        Shock? $shock = bike.shock ?? null;
        final String forkProduct = $fork != null ? '${$fork.year + ' ' + $fork.brand + ' ' + $fork.model}' : '';
        final String shockProduct = $shock != null ? '${$shock.year + ' ' + $shock.brand + ' ' + $shock.model}' : '';

        return Dismissible(
          background: ListTile(
            // tileColor: CupertinoColors.extraLightBackgroundGray.withOpacity(0.5),
            trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
            shape: null,
          ),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) => setState(() {
            db.deleteSetting(bike.id, settings[index].id);
            settings.removeAt(index);
          }),
          key: PageStorageKey(settings[index]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                key: PageStorageKey(settings[index]),
                child: ListTile(
                  title: Text(settings[index].id),
                  subtitle: Text(widget.bike.id),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // shape: null,
                ),
                onTap: () {
                  SettingDetails details = SettingDetails(
                    bike: widget.bike,
                    name: settings[index].id,
                    fork: fork,
                    shock: shock,
                    frontTire: frontTire,
                    rearTire: rearTire,
                    notes: notes,
                  );
                  pushScreen(
                    context,
                    settings[index].id,
                    [ShareButton(widget: details, forkProduct: forkProduct, shockProduct: shockProduct)],
                    details,
                    true,
                  );
                }),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StreamBuilder<List<Setting>>(
            stream: db.streamSettings(widget.bike.id),
            builder: (context, snapshot) {
              var settings = snapshot.data;
              if (settings == null) {
                return Center(child: CircularProgressIndicator.adaptive());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString(), style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
                );
              }
              return _getSettings(widget.bike, settings, context);
            }),
        ElevatedButton(
          child: Text('Add Setting'),
          onPressed: () => pushScreen(context, 'Add Setting', null, SettingDetails(bike: widget.bike), true),
        ),
        Expanded(child: Container())
      ],
    );
  }
}
