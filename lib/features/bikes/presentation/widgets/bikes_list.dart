import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/features/bikes/presentation/screens/bike_wizard_screen.dart';
import 'package:ridemetrx/features/bikes/presentation/screens/fork_form.dart';
import 'package:ridemetrx/features/bikes/presentation/screens/settings_list.dart';
import 'package:ridemetrx/features/bikes/presentation/screens/shock_form.dart';
import 'package:ridemetrx/features/bikes/domain/bikes_notifier.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/presentation/view_models/bikes_list_view_model.dart';
import 'package:ridemetrx/features/bikes/presentation/view_models/bike_image_view_model.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/core/utilities/helpers.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';
import 'package:ridemetrx/features/purchases/presentation/screens/paywall_screen.dart';
import 'package:ridemetrx/core/services/haptic_service.dart';

class BikesList extends ConsumerStatefulWidget {
  const BikesList({Key? key, required this.bikes}) : super(key: key);
  final List<Bike> bikes;

  @override
  ConsumerState<BikesList> createState() => _BikesListState();
}

class _BikesListState extends ConsumerState<BikesList> {
  late Bike? _selectedBike = Bike(id: '');
  bool finished = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    Future.delayed(Duration.zero, () {
      setState(() => finished = !finished);
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.read(databaseServiceProvider);
    // Watch the provider to ensure it's initialized before accessing notifier
    ref.watch(bikesNotifierProvider);
    List<Bike> bikes = widget.bikes;

    return SafeArea(
      child: AnimatedSlide(
        offset: finished ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReorderableListView.builder(
                    onReorder: (oldIndex, newIndex) {
                      HapticService.medium();
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final bike = bikes.removeAt(oldIndex);
                        bikes.insert(newIndex, bike);
                        for (Bike bike in bikes) {
                          bike.index = bikes.indexOf(bike);
                          db.reorderBike(bike.id, bike.index!);
                        }
                      });
                    },
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: bikes.length,
                    itemBuilder: (context, index) {
                      Bike bike = bikes[index];
                      final bikesListViewModel = ref.read(bikesListViewModelProvider.notifier);
                      String bikeName = bikesListViewModel.formatBikeName(bike);
                      var fork = bike.fork;
                      var shock = bike.shock;

                      return Dismissible(
                        background: ListTile(
                          tileColor: CupertinoColors.destructiveRed.withValues(alpha: 0.125),
                          trailing: const Icon(Icons.delete, color: CupertinoColors.systemRed),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          HapticService.medium();
                          return await _confirmDelete(context, bike.id, null);
                        },
                        key: ValueKey(bike.id),
                        child: Container(
                          decoration: index != bikes.length - 1
                              ? BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                )
                              : null,
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              onExpansionChanged: (expanded) {
                                HapticService.light();
                              },
                              leading: bike.bikePic == null || bike.bikePic!.isEmpty
                                  ? Stack(
                                      children: [
                                        CupertinoButton(
                                          padding: const EdgeInsets.only(bottom: 0),
                                          child: const Icon(Icons.add_a_photo, size: 28),
                                          onPressed: () async {
                                            HapticService.medium();
                                            final isPro = ref.read(purchaseNotifierProvider).isPro;
                                            if (isPro) {
                                              final bikeImageViewModel = ref.read(bikeImageViewModelProvider.notifier);
                                              await bikeImageViewModel.uploadBikeImage(bike.id);
                                            } else {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    fullscreenDialog: true,
                                                    builder: (context) => PaywallScreen(showAppBar: true)),
                                              );
                                            }
                                          },
                                        ),
                                        // Pro badge indicator
                                        if (!ref.watch(purchaseNotifierProvider).isPro)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.shade600,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 10,
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  : CircleAvatar(
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: bike.bikePic!,
                                          fit: BoxFit.cover,
                                          width: 40,
                                          height: 40,
                                          placeholder: (context, url) => const Icon(Icons.pedal_bike_sharp),
                                          errorWidget: (context, url, error) => const Icon(Icons.photo_camera),
                                        ),
                                      ),
                                    ),
                              initiallyExpanded: _selectedBike!.id == bike.id,
                              key: PageStorageKey(bike),
                              title: Text(bikeName, style: const TextStyle(fontSize: 18)),
                              children: [
                                // Fork section
                                fork != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.extraLightBackgroundGray.withValues(alpha: 0.5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              width: 35,
                                              height: 35,
                                              child: Image.asset('assets/fork.png'),
                                            ),
                                            Container(
                                              padding: EdgeInsets.zero,
                                              alignment: Alignment.centerLeft,
                                              width: 200,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                dense: true,
                                                title: Text(
                                                  '${fork.year} ${fork.brand} ${fork.model}',
                                                  style: const TextStyle(color: Colors.black87),
                                                ),
                                                subtitle: Text(
                                                  '${fork.travel != null ? fork.travel! + 'mm' : ''}${fork.damper != null ? ' / ' + fork.damper! : ''}${fork.offset != null ? ' / ' + fork.offset! + 'mm' : ''}${fork.wheelsize != null ? ' / ' + fork.wheelsize! + '"' : ''}',
                                                  style: const TextStyle(color: Colors.black54),
                                                ),
                                                onTap: () {
                                                  HapticService.light();
                                                  pushScreen(
                                                    context,
                                                    '${fork.brand} ${fork.model}',
                                                    null,
                                                    ForkForm(bikeId: bike.id, fork: fork),
                                                    true,
                                                  );
                                                  setState(() => _selectedBike = bike);
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline_sharp,
                                                size: 16,
                                                color: Colors.black38,
                                              ),
                                              onPressed: () {
                                                HapticService.light();
                                                _confirmDelete(context, bike.id, 'fork');
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.extraLightBackgroundGray.withValues(alpha: 0.5),
                                        ),
                                        child: OutlinedButton(
                                          style: ElevatedButton.styleFrom(
                                            alignment: Alignment.center,
                                            fixedSize: const Size(280, 20),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            backgroundColor: CupertinoColors.extraLightBackgroundGray,
                                            foregroundColor: CupertinoColors.black,
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.add_circle_outline, size: 16, color: Colors.grey),
                                              SizedBox(width: 10),
                                              Text(' Add Fork'),
                                            ],
                                          ),
                                          onPressed: () {
                                            HapticService.light();
                                            pushScreen(
                                              context,
                                              'Add Fork',
                                              null,
                                              ForkForm(bikeId: bike.id, fork: fork),
                                              true,
                                            );
                                            setState(() => _selectedBike = bike);
                                          },
                                        ),
                                      ),
                                // Shock section
                                shock != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.extraLightBackgroundGray.withValues(alpha: 0.5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              width: 35,
                                              height: 35,
                                              child: Image.asset('assets/shock.png'),
                                            ),
                                            Container(
                                              padding: EdgeInsets.zero,
                                              alignment: Alignment.centerLeft,
                                              width: 200,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                dense: true,
                                                title: Text(
                                                  '${shock.year} ${shock.brand} ${shock.model}',
                                                  style: const TextStyle(color: Colors.black87),
                                                ),
                                                subtitle: Text(
                                                  shock.stroke ?? '',
                                                  style: const TextStyle(color: Colors.black54),
                                                ),
                                                onTap: () {
                                                  HapticService.light();
                                                  pushScreen(
                                                    context,
                                                    '${shock.brand} ${shock.model}',
                                                    null,
                                                    ShockForm(bikeId: bike.id, shock: shock),
                                                    true,
                                                  );
                                                  setState(() => _selectedBike = bike);
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline_sharp,
                                                size: 16,
                                                color: Colors.black38,
                                              ),
                                              onPressed: () {
                                                HapticService.light();
                                                _confirmDelete(context, bike.id, 'shock');
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        width: double.maxFinite,
                                        padding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.extraLightBackgroundGray.withValues(alpha: 0.5),
                                        ),
                                        child: OutlinedButton(
                                          style: ElevatedButton.styleFrom(
                                            alignment: Alignment.center,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            backgroundColor: CupertinoColors.extraLightBackgroundGray,
                                            foregroundColor: CupertinoColors.black,
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.add_circle_outline, size: 16, color: Colors.grey),
                                              SizedBox(width: 10),
                                              Text(' Add Shock'),
                                            ],
                                          ),
                                          onPressed: () {
                                            HapticService.light();
                                            pushScreen(
                                              context,
                                              'Add Shock',
                                              null,
                                              ShockForm(bikeId: bike.id, shock: shock),
                                              true,
                                            );
                                            setState(() => _selectedBike = bike);
                                          },
                                        ),
                                      ),
                                // Settings section
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                  ),
                                  child: GestureDetector(
                                    child: const ListTile(
                                      leading: Icon(CupertinoIcons.settings, color: Colors.black54),
                                      title: Text('Ride Settings', style: TextStyle(color: Colors.black87)),
                                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.black38),
                                    ),
                                    onTap: () {
                                      HapticService.light();
                                      pushScreen(context, bike.id, null, SettingsList(bike: bike), false);
                                      setState(() => _selectedBike = bike);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ElevatedButton(
                    child: const Text('Add Bike'),
                    onPressed: () {
                      HapticService.medium();
                      pushScreen(context, 'Add Bike', null, BikeWizardScreen(), true);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String bikeId, String? component) {
    HapticService.warning();
    final db = ref.read(databaseServiceProvider);
    final bikesNotifier = ref.read(bikesNotifierProvider.notifier);
    String settingName = component != null ? component : bikeId;

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text('Delete $settingName'),
          content: Text('Are you sure you want to delete the $settingName? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, true);
                if (component == null) {
                  // Use BikesNotifier for proper tombstone deletion
                  bikesNotifier.deleteBike(bikeId);
                } else if (component == 'fork' || component == 'shock') {
                  // 1. Delete component from its box
                  final boxName = component == 'fork' ? 'forks' : 'shocks';
                  final componentBox = await Hive.openBox(boxName);
                  await componentBox.delete(bikeId);
                  print('BikesList: $component deleted from $boxName box for bike $bikeId');

                  // 2. Update the bike object to remove the component reference
                  final bikesBox = await Hive.openBox<Bike>('bikes');
                  final bike = bikesBox.get(bikeId);
                  if (bike != null) {
                    final updatedBike = component == 'fork' ? bike.copyWith(fork: null) : bike.copyWith(shock: null);
                    await bikesBox.put(bikeId, updatedBike);
                    print('BikesList: Updated bike object to remove $component reference');
                  }

                  // 3. Only sync to Firebase if user is Pro
                  final isPro = ref.read(purchaseNotifierProvider).isPro;
                  if (isPro) {
                    await db.deleteField(bikeId, component);
                    print('BikesList: $component deletion synced to Firebase for bike $bikeId');
                  } else {
                    print('BikesList: User is not Pro, $component deleted locally only');
                  }

                  // 4. Refresh BikesNotifier to trigger UI rebuild
                  bikesNotifier.refreshFromHive();
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return Future.value(false);
  }
}
