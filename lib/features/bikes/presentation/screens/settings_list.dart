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
import 'package:inline_list_tile_actions/inline_list_tile_actions.dart';
import 'setting_detail.dart';

class SettingsList extends ConsumerStatefulWidget {
  SettingsList({required this.bike});
  final Bike bike;

  @override
  ConsumerState<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends ConsumerState<SettingsList> {
  final List<GlobalKey<InlineListTileActionsState>> _actionKeys = [];

  void _closeOtherMenus(int expandedIndex) {
    for (int i = 0; i < _actionKeys.length; i++) {
      if (i != expandedIndex) {
        _actionKeys[i].currentState?.close();
      }
    }
  }

  void _ensureKeysInitialized(int settingsCount) {
    // Add keys if we don't have enough
    while (_actionKeys.length < settingsCount) {
      _actionKeys.add(GlobalKey<InlineListTileActionsState>());
    }
    // Remove excess keys if settings were deleted
    while (_actionKeys.length > settingsCount) {
      _actionKeys.removeLast();
    }
  }

  Widget _getSettings(BuildContext context, Bike bike, List<Setting> settings) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: settings.length,
      itemBuilder: (context, index) {
        ComponentSetting? forkSettings = settings[index].fork ?? null;
        ComponentSetting? shockSettings = settings[index].shock ?? null;
        String? frontTire = settings[index].frontTire ?? null;
        String? rearTire = settings[index].rearTire ?? null;
        String? notes = settings[index].notes ?? null;
        Fork? $fork = bike.fork ?? null;
        Shock? $shock = bike.shock ?? null;
        final String forkProduct = $fork != null ? '${$fork.year + ' ' + $fork.brand + ' ' + $fork.model}' : '';
        final String shockProduct = $shock != null ? '${$shock.year + ' ' + $shock.brand + ' ' + $shock.model}' : '';

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: InlineListTileActions(
            key: _actionKeys[index],
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                _closeOtherMenus(index);
              }
            },
            actionPosition: ActionPosition.inline,
            actions: [
              ActionItem(
                icon: Icons.delete,
                label: 'Delete',
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: () {
                  final settingsNotifier = ref.read(settingsNotifierProvider(bike.id).notifier);
                  settingsNotifier.deleteSetting(settings[index].id);
                  print('Delete tapped');
                },
              ),
              ActionItem(
                icon: Icons.copy,
                label: 'Clone',
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clone feature coming soon!'),
                      backgroundColor: Colors.amber,
                    ),
                  );
                },
              ),
              ActionItem(
                icon: Icons.share,
                label: 'Share',
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share feature coming soon!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ],
            child: ListTile(
              title: Text(settings[index].id),
              subtitle: Text(widget.bike.id),
              onTap: () {
                // Close all action menus before navigating
                for (var key in _actionKeys) {
                  key.currentState?.close();
                }

                SettingDetails details = SettingDetails(
                  bike: widget.bike,
                  name: settings[index].id,
                  fork: forkSettings,
                  shock: shockSettings,
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
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the settings provider to get the latest data
    final settings = ref.watch(settingsNotifierProvider(widget.bike.id));

    // Ensure we have the right number of action keys
    _ensureKeysInitialized(settings.length);

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
