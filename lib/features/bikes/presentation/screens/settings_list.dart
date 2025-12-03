import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/bikes/presentation/widgets/share_button.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/component_setting.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'package:ridemetrx/core/utilities/helpers.dart';
import 'package:ridemetrx/features/bikes/domain/settings_notifier.dart';
import 'package:ridemetrx/features/bikes/presentation/view_models/settings_list_view_model.dart';
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

  Future<bool?> _showDeleteDialog(BuildContext context, String settingName) {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Delete Setting?'),
        content: Text('Are you sure you want to delete the setting "$settingName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showCloneDialog(BuildContext context, String defaultName) async {
    final controller = TextEditingController(text: defaultName);

    return showAdaptiveDialog<String>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Clone Setting'),
        content: CupertinoTextField(
          controller: controller,
          autofocus: true,
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(8),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Clone'),
          ),
        ],
      ),
    );
  }

  Widget _getSettings(BuildContext context, Bike bike, List<Setting> settings) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      onReorder: (oldIndex, newIndex) async {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final setting = settings.removeAt(oldIndex);
          settings.insert(newIndex, setting);

          // Update indices for all settings
          for (int i = 0; i < settings.length; i++) {
            settings[i].index = i;
          }
        });

        // Save the new order to Hive and Firebase
        final viewModel = ref.read(settingsListViewModelProvider.notifier);
        await viewModel.reorderSettings(settings, bike.id);
      },
      itemCount: settings.length,
      itemBuilder: (context, index) {
        final setting = settings[index];
        final viewModel = ref.read(settingsListViewModelProvider.notifier);

        final ComponentSetting? forkSettings = setting.fork;
        final ComponentSetting? shockSettings = setting.shock;
        final String? frontTire = setting.frontTire;
        final String? rearTire = setting.rearTire;
        final String? notes = setting.notes;
        final String forkProduct = viewModel.formatForkProduct(bike);
        final String shockProduct = viewModel.formatShockProduct(bike);

        return Padding(
          key: ValueKey(setting.id),
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
                onPressed: () async {
                  final confirmed = await _showDeleteDialog(context, setting.id);
                  if (confirmed == true) {
                    await viewModel.deleteSetting(
                      settingId: setting.id,
                      bikeId: bike.id,
                    );
                  }
                },
              ),
              ActionItem(
                icon: Icons.copy,
                label: 'Clone',
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                onPressed: () async {
                  // Close the action menu
                  _actionKeys[index].currentState?.close();

                  final defaultName = viewModel.generateCloneName(setting.id);

                  // Show dialog to get new name
                  final newName = await _showCloneDialog(context, defaultName);

                  if (newName != null && newName.isNotEmpty) {
                    final success = await viewModel.cloneSetting(
                      originalSetting: setting,
                      newName: newName,
                      bikeId: bike.id,
                    );

                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Setting cloned as "$newName"'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
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
              title: Text(setting.id),
              subtitle: Text(widget.bike.id),
              onTap: () {
                // Close all action menus before navigating
                for (var key in _actionKeys) {
                  key.currentState?.close();
                }

                SettingDetails details = SettingDetails(
                  bike: widget.bike,
                  name: setting.id,
                  fork: forkSettings,
                  shock: shockSettings,
                  frontTire: frontTire,
                  rearTire: rearTire,
                  notes: notes,
                );
                pushScreen(
                  context,
                  setting.id,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: ListTile(
            tileColor: Colors.blue.shade50,
            leading: Icon(Icons.info_outline),
            minLeadingWidth: 0,
            title: Text(
              '• Add settings for each trail or condition \n• Drag and drop to reorder settings \n• Tap the menu icon to delete, clone or share',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
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
