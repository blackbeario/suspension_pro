import 'package:flutter/material.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'models/bike.dart';
import 'models/user.dart';

class SettingDetails extends StatefulWidget {
  SettingDetails({required this.user, this.setting, this.bike, this.fork, this.shock, this.frontTire, this.rearTire, this.notes});

  final AppUser user;
  final String? setting, frontTire, rearTire, notes;
  final Bike? bike;
  final Map? fork, shock;

  @override
  _SettingDetailsState createState() => _SettingDetailsState();
}

class _SettingDetailsState extends State<SettingDetails> {
  final _formKey = GlobalKey<FormState>();
  final db = DatabaseService();
  final _settingNameController = TextEditingController();
  final _hscForkController = TextEditingController();
  final _lscForkController = TextEditingController();
  final _hsrForkController = TextEditingController();
  final _lsrForkController = TextEditingController();
  final _springRateForkController = TextEditingController();
  final _frontTireController = TextEditingController();
  final _hscShockController = TextEditingController();
  final _lscShockController = TextEditingController();
  final _hsrShockController = TextEditingController();
  final _lsrShockController = TextEditingController();
  final _springRateShockController = TextEditingController();
  final _rearTireController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var $setting = widget.setting;
    var $fork = widget.fork;
    var $shock = widget.shock;
    _settingNameController.text = $setting != null ? $setting : '';

    _hscForkController.text = $fork?['HSC'] ?? '';
    _lscForkController.text = $fork?['LSC'] ?? '';
    _hsrForkController.text = $fork?['HSR'] ?? '';
    _lsrForkController.text = $fork?['LSR'] ?? '';
    _springRateForkController.text = $fork?['springRate'] ?? '';

    _hscShockController.text = $shock?['HSC'] ?? '';
    _lscShockController.text = $shock?['LSC'] ?? '';
    _hsrShockController.text = $shock?['HSR'] ?? '';
    _lsrShockController.text = $shock?['LSR'] ?? '';
    _springRateShockController.text = $shock?['springRate'] ?? '';

    _frontTireController.text = widget.frontTire ?? '';
    _rearTireController.text = widget.rearTire ?? '';

    _notesController.text = widget.notes ?? '';
  }

  @override
  void dispose() {
    _hscForkController.dispose();
    _lscForkController.dispose();
    _hsrForkController.dispose();
    _lsrForkController.dispose();
    _springRateForkController.dispose();
    _hscShockController.dispose();
    _lscShockController.dispose();
    _hsrShockController.dispose();
    _lsrShockController.dispose();
    _springRateShockController.dispose();
    _settingNameController.dispose();
    _frontTireController.dispose();
    _rearTireController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<bool> _updateSetting(bikeId, BuildContext context) {
    Navigator.pop(context);
    db.updateSetting(
      widget.user.id,
      bikeId,
      _settingNameController.text,
      _hscForkController.text,
      _lscForkController.text,
      _hsrForkController.text,
      _lsrForkController.text,
      _springRateForkController.text,
      _hscShockController.text,
      _lscShockController.text,
      _hsrShockController.text,
      _lsrShockController.text,
      _springRateShockController.text,
      _frontTireController.text,
      _rearTireController.text,
      _notesController.text,
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    var $fork = widget.bike != null ? widget.bike!.fork : null;
    var $shock = widget.bike != null ? widget.bike!.shock : null;

    // This would be saved in a singleton class if building this in 2024
    // instead of repeating this all over the app. Rookie shit from 2020.
    return StreamBuilder<AppUser?>(
      stream: db.streamUser(widget.user.id),
      builder: (context, snapshot) {
        var myUser = snapshot.data;

        if (myUser == null) {
          return Center(child: CupertinoActivityIndicator(animating: true));
        }
        return CupertinoPageScaffold(
          resizeToAvoidBottomInset: true,
          navigationBar: CupertinoNavigationBar(
            middle: Text(widget.setting ?? 'New Setting'),
            trailing: TextButton.icon(
              label: Text('Share'),
              icon: Icon(CupertinoIcons.share, size: 20),
              onPressed: () =>
                  _share(context, myUser, widget.setting!, $fork, widget.fork, $shock, widget.shock, widget.frontTire, widget.rearTire),
            ),
          ),
          child: Material(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextFormField(
                          validator: (_settingNameController) {
                            if (_settingNameController == null || _settingNameController.isEmpty) return 'Please add a setting title';
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.settings, size: 24, color: CupertinoColors.activeBlue.withOpacity(0.5)),
                            isDense: true,
                            filled: true,
                            hoverColor: Colors.blue.shade100,
                            border: OutlineInputBorder(),
                            hintText: 'Setting Name',
                          ),
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          controller: _settingNameController,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      // SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Column(children: <Widget>[
                              SizedBox(
                                child: Text($fork != null ? $fork['brand'] + ' ' + $fork['model'] : 'No fork saved'),
                                height: 25,
                              ),
                              Container(
                                  padding: EdgeInsets.all(2),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset('assets/fork.png')),
                              SizedBox(height: 20),
                              TextField(
                                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'HSC',
                                    labelText: 'HSC',
                                  ),
                                  controller: _hscForkController,
                                  keyboardType: TextInputType.number),
                              TextField(
                                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'LSC',
                                    labelText: 'LSC',
                                  ),
                                  controller: _lscForkController,
                                  keyboardType: TextInputType.number),
                              TextField(
                                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'HSR',
                                    labelText: 'HSR',
                                  ),
                                  controller: _hsrForkController,
                                  keyboardType: TextInputType.number),
                              TextField(
                                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'LSR',
                                    labelText: 'LSR',
                                  ),
                                  controller: _lsrForkController,
                                  keyboardType: TextInputType.number),
                              TextField(
                                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'SPRING / PSI',
                                    labelText: 'SPRING / PSI',
                                  ),
                                  controller: _springRateForkController,
                                  keyboardType: TextInputType.number),
                              TextField(
                                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'FRONT TIRE PSI',
                                    labelText: 'FRONT TIRE PSI',
                                  ),
                                  controller: _frontTireController,
                                  keyboardType: TextInputType.number),
                            ]),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  child: Text($shock != null ? $shock['brand'] + ' ' + $shock['model'] : 'No shock saved'),
                                  height: 25,
                                ),
                                Container(
                                    padding: EdgeInsets.all(2),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset('assets/shock.png')),
                                SizedBox(height: 20),
                                TextField(
                                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: 'HSC',
                                      labelText: 'HSC',
                                    ),
                                    controller: _hscShockController,
                                    keyboardType: TextInputType.number),
                                TextField(
                                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: 'LSC',
                                      labelText: 'LSC',
                                    ),
                                    controller: _lscShockController,
                                    keyboardType: TextInputType.number),
                                TextField(
                                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: 'HSR',
                                      labelText: 'HSR',
                                    ),
                                    controller: _hsrShockController,
                                    keyboardType: TextInputType.number),
                                TextField(
                                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: 'LSR',
                                      labelText: 'LSR',
                                    ),
                                    controller: _lsrShockController,
                                    keyboardType: TextInputType.number),
                                TextField(
                                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: 'SPRING / PSI',
                                      labelText: 'SPRING / PSI',
                                    ),
                                    controller: _springRateShockController,
                                    keyboardType: TextInputType.number),
                                TextField(
                                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: 'REAR TIRE PSI',
                                      labelText: 'REAR TIRE PSI',
                                    ),
                                    controller: _rearTireController,
                                    keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: Text('Notes'),
                        children: [
                          TextField(
                            maxLines: 4,
                            controller: _notesController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              hintText: 'Custom notes for this setting',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      CupertinoButton(
                        color: CupertinoColors.activeBlue,
                        child: Text('Save'),
                        onPressed: _settingNameController.text.isNotEmpty
                            ? () async {
                                if (_formKey.currentState!.validate()) {
                                  await _updateSetting(widget.bike!.id, context);
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _share(context, AppUser myUser, String setting, fork, forkSettings, shock, shockSettings, frontTire, rearTire) async {
    late String text;
    if (shock != null) {
      text =
          "Suspension Pro '$setting' shared by ${myUser.username} \n\n${fork['year'] + ' ' + fork['brand'] + ' ' + fork['model']} Fork Settings: \n$forkSettings, \n\n${shock['year'] + ' ' + shock['brand'] + ' ' + shock['model']} Shock Settings: \n$shockSettings, \n\nFront Tire: \n$frontTire, /n/nRear Tire: \n$rearTire \n\nGet the Suspension Pro App for iOS soon on the Apple AppStore!";
    } else {
      text =
          "Suspension Pro '$setting' shared by ${myUser.username} \n\n${fork['year'] + ' ' + fork['brand'] + ' ' + fork['model']} Fork Settings: \n$forkSettings, \n\nFront Tire: \n$frontTire, /n/nRear Tire: \n$rearTire \n\nGet the Suspension Pro App for iOS soon on the Apple AppStore!";
    }
    Share.share(text, subject: setting);
    await _addSharePoints(myUser, 1);
  }

  _addSharePoints(AppUser myUser, int value) {
    // Not updated since we're passing in the user. Need to get user from a stream.
    int? currentPoints = myUser.points ?? 0;
    String role = myUser.role!;
    db.addSharePoints(widget.user.id, currentPoints, role);
  }
}
