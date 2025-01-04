import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:suspension_pro/features/forms/fork_form.dart';
import 'package:suspension_pro/features/forms/shock_form.dart';
import 'package:suspension_pro/features/bikes/bikes_bloc.dart';
import 'package:suspension_pro/features/bike_settings/settings_list.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/services/db_service.dart';

class BikesList extends StatefulWidget {
  const BikesList({Key? key, required this.bikes}) : super(key: key);
  final List<Bike> bikes;

  @override
  State<BikesList> createState() => _BikesListState();
}

class _BikesListState extends State<BikesList> {
  final db = DatabaseService();
  final BikesBloc _bloc = BikesBloc();
  late Bike? _selectedBike = Bike(id: '');
  var imagePicker;

  @override
  Widget build(BuildContext context) {
    List<Bike> bikes = widget.bikes;
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
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
        Bike $bike = bikes[index];
        String bikeName = _bloc.parseBikeName($bike);
        var fork = $bike.fork;
        var shock = $bike.shock;
        return Dismissible(
          background: ListTile(
            tileColor: CupertinoColors.destructiveRed.withOpacity(0.125),
            trailing: Icon(Icons.delete, color: CupertinoColors.systemRed),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await _confirmDelete(context, $bike.id, null);
          },
          key: ValueKey($bike.id),
          child: Container(
            decoration: index != bikes.length - 1
                ? BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    // color: index.isEven ? Colors.amber : Colors.blue
                  )
                : null,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Container(
                  // bikePic could be null if not synced to FB
                  child: $bike.bikePic == null || $bike.bikePic!.isEmpty
                      ? CupertinoButton(
                          padding: EdgeInsets.only(bottom: 0),
                          child: Icon(Icons.photo_camera),
                          onPressed: () => _bloc.getFromGallery($bike.id))
                      : CircleAvatar(
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: $bike.bikePic!,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              placeholder: (context, url) => Icon(Icons.pedal_bike_sharp),
                              errorWidget: (context, url, error) => Icon(Icons.photo_camera),
                            ),
                          ),
                        ),
                ),
                initiallyExpanded: _selectedBike!.id == $bike.id ? true : false,
                key: PageStorageKey($bike),
                title: Text(bikeName, style: TextStyle(fontSize: 18)),
                children: [
                  fork != null
                      ? Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.extraLightBackgroundGray.withOpacity(0.5),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(2),
                                    width: 35,
                                    height: 35,
                                    child: Image.asset('assets/fork.png')),
                                Container(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft,
                                  width: 200,
                                  child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      title: Text(fork["year"].toString() + ' ' + fork["brand"] + ' ' + fork["model"],
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
                                                  navigationBar: CupertinoNavigationBar(
                                                    /// This should allow me to pass the $bike argument back to the Setting
                                                    /// screen so we can expand the appropriate expansion panel.
                                                    leading: CupertinoButton(
                                                        child: BackButtonIcon(),
                                                        onPressed: () => Navigator.pop(context, $bike.id)),
                                                    middle: Text(fork['brand'] + ' ' + fork['model']),
                                                  ),
                                                  child: ForkForm(bikeId: $bike.id, fork: fork),
                                                );
                                              }),
                                        );
                                        setState(() {
                                          _selectedBike = $bike;
                                        });
                                      }),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline_sharp, size: 16, color: Colors.black38),
                                  onPressed: () {
                                    _confirmDelete(context, $bike.id, 'fork');
                                  },
                                ),
                              ]),
                        )
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: CupertinoColors.extraLightBackgroundGray.withOpacity(0.5),
                          ),
                          child: OutlinedButton(
                            style: ElevatedButton.styleFrom(
                              alignment: Alignment.center,
                              fixedSize: Size(280, 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: CupertinoColors.extraLightBackgroundGray,
                              foregroundColor: CupertinoColors.black,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add),
                                Text(' Add Fork'),
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
                                              onPressed: () => Navigator.pop(context, $bike.id)),
                                          middle: Text('Add Fork'),
                                        ),
                                        child: ForkForm(bikeId: $bike.id, fork: fork),
                                      );
                                    },
                                  ));
                              setState(() {
                                _selectedBike = $bike;
                              });
                            },
                          ),
                        ),
                  // If shock data exists populate info and link to settings.
                  shock != null
                      ? Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.extraLightBackgroundGray.withOpacity(0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                width: 35,
                                height: 35,
                                // decoration: BoxDecoration(
                                //   color: Colors.white,
                                //   shape: BoxShape.circle,
                                // ),
                                child: Image.asset('assets/shock.png'),
                              ),
                              Container(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                                width: 200,
                                child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(shock["year"].toString() + ' ' + shock["brand"] + ' ' + shock["model"],
                                        style: TextStyle(color: Colors.black87)),
                                    subtitle: Text(shock["stroke"] ?? '', style: TextStyle(color: Colors.black54)),
                                    onTap: () async {
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
                                                      onPressed: () => Navigator.pop(context, $bike.id)),
                                                  middle: Text(shock['brand'] + ' ' + shock['model']),
                                                ),
                                                child: ShockForm(bikeId: $bike.id, shock: shock),
                                              );
                                            },
                                          ));
                                      setState(() {
                                        _selectedBike = $bike;
                                      });
                                    }),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline_sharp, size: 16, color: Colors.black38),
                                onPressed: () {
                                  _confirmDelete(context, $bike.id, 'shock');
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: CupertinoColors.extraLightBackgroundGray.withOpacity(0.5),
                          ),
                          child: OutlinedButton(
                            style: ElevatedButton.styleFrom(
                              alignment: Alignment.center,
                              // fixedSize: Size(100, 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: CupertinoColors.extraLightBackgroundGray,
                              foregroundColor: CupertinoColors.black,
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
                                              onPressed: () => Navigator.pop(context, $bike.id)),
                                          middle: Text('Add Shock'),
                                        ),
                                        child: ShockForm(bikeId: $bike.id, shock: shock),
                                      );
                                    },
                                  ));
                              setState(() {
                                _selectedBike = $bike;
                              });
                            },
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.extraLightBackgroundGray,
                    ),
                    child: GestureDetector(
                        child: ListTile(
                          leading: Icon(CupertinoIcons.settings, color: Colors.black54),
                          title: Text('Ride Settings', style: TextStyle(color: Colors.black87)),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.black38),
                        ),
                        onTap: () async {
                          await Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                            // Return the shock detail form screen here.
                            return SettingsList(bike: $bike);
                          }));
                          setState(() {
                            _selectedBike = $bike;
                          });
                        }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, bikeId, String? component) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog.adaptive(
            title: component != null ? Text('Delete $component') : Text('Delete $bikeId'),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Okay'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, true);
                    if (component == null) db.deleteBike(bikeId);
                    if (component != null) db.deleteField(bikeId, component);
                  }),
              CupertinoDialogAction(
                child: Text('Cancel'),
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          );
        });
    return new Future.value(false);
  }
}
