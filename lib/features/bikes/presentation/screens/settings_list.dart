import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:suspension_pro/features/bikes/presentation/widgets/get_ai_button.dart';
import 'package:suspension_pro/features/bikes/presentation/widgets/share_button.dart';
import 'package:suspension_pro/features/bikes/domain/models/bike.dart';
import 'package:suspension_pro/features/bikes/domain/models/component_setting.dart';
import 'package:suspension_pro/features/bikes/domain/models/fork.dart';
import 'package:suspension_pro/features/bikes/domain/models/setting.dart';
import 'package:suspension_pro/features/bikes/domain/models/shock.dart';
import 'package:suspension_pro/core/utilities/helpers.dart';
import 'package:suspension_pro/core/providers/service_providers.dart';
import 'setting_detail.dart';
import 'package:flutter/cupertino.dart';

class SettingsList extends ConsumerStatefulWidget {
  SettingsList({required this.bike});
  final Bike bike;

  @override
  ConsumerState<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends ConsumerState<SettingsList> {
  List<Setting> settings = [];

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  getSettings() async {
    settings = await _getBikeSettingsFromHive(widget.bike.id);
    setState(() {});
  }

  Future<List<Setting>> _getBikeSettingsFromHive(String bikeId) async {
    List<String> keysList = [];
    List<Setting> settingsList = [];
    var box = Hive.box<Setting>('settings');
    var boxKeys = box.keys;
    for (var key in boxKeys) keysList.add(key);
    var bikeSettings = keysList.where((String key) => key.contains(bikeId));
    for (String key in bikeSettings) {
      Setting setting = box.get(key)!;
      settingsList.add(setting);
    }
    return settingsList;
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
            trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
            shape: null,
          ),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) => setState(() {
            final key = bike.id + '-' + settings[index].id;
            Hive.box<Setting>('settings').delete(key);
            final db = ref.read(databaseServiceProvider);
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
          child: Text('Add Manual Setting'),
          onPressed: () => pushScreen(context, 'Add Setting', null, SettingDetails(bike: widget.bike), true),
          style: ElevatedButton.styleFrom(fixedSize: Size(240, 50)),
        ),
        SizedBox(height: 30),
        GetAiButton(bike: widget.bike),
        Expanded(child: Container())
      ],
    );
  }
}