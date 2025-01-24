import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:suspension_pro/core/services/hive_service.dart';
import 'package:suspension_pro/views/bike_settings/share_button.dart';
import 'package:suspension_pro/core/models/bike.dart';
import 'package:suspension_pro/core/models/component_setting.dart';
import 'package:suspension_pro/core/models/fork.dart';
import 'package:suspension_pro/core/models/setting.dart';
import 'package:suspension_pro/core/models/shock.dart';
import 'package:suspension_pro/core/utilities/helpers.dart';
import 'package:suspension_pro/views/bikes/bikes_bloc.dart';
import 'setting_detail.dart';
import 'package:suspension_pro/core/services/db_service.dart';
import 'package:flutter/cupertino.dart';

class SettingsList extends StatefulWidget {
  SettingsList({required this.bike});
  final Bike bike;

  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  final db = DatabaseService();
  List<Setting> settings = [];

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  getSettings() async {
    settings = await BikesBloc().getBikeSettingsFromHive(widget.bike.id);
    setState(() {});
  }

  Widget _getSettings(BuildContext context, Bike bike) {
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
        _getSettings(context, widget.bike),
        ElevatedButton(
          child: Text('Add Setting'),
          onPressed: () => pushScreen(context, 'Add Setting', null, SettingDetails(bike: widget.bike), true),
        ),
        Expanded(child: Container())
      ],
    );
  }
}
