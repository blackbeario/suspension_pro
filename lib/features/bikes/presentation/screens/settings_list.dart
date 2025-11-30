import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/bikes/presentation/widgets/share_button.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/component_setting.dart';
import 'package:ridemetrx/features/bikes/domain/models/fork.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/features/bikes/domain/models/shock.dart';
import 'package:ridemetrx/core/utilities/helpers.dart';
import 'package:ridemetrx/features/bikes/domain/settings_notifier.dart';
import 'setting_detail.dart';
import 'package:flutter/cupertino.dart';

class SettingsList extends ConsumerStatefulWidget {
  SettingsList({required this.bike});
  final Bike bike;

  @override
  ConsumerState<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends ConsumerState<SettingsList> {
  Widget _getSettings(BuildContext context, Bike bike, List<Setting> settings) {
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
          onDismissed: (direction) {
            final settingsNotifier = ref.read(settingsNotifierProvider(bike.id).notifier);
            settingsNotifier.deleteSetting(settings[index].id);
          },
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
    // Watch the settings provider for the current bike
    final settings = ref.watch(settingsNotifierProvider(widget.bike.id));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _getSettings(context, widget.bike, settings),
        SizedBox(height: 20),
        ElevatedButton(
          child: Text('Add Manual Setting'),
          onPressed: () {
            pushScreen(context, 'Add Setting', null, SettingDetails(bike: widget.bike), true);
          },
          style: ElevatedButton.styleFrom(fixedSize: Size(240, 50)),
        ),
        Expanded(child: Container())
      ],
    );
  }
}