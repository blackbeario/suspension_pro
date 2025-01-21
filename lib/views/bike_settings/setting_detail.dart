import 'package:flutter/material.dart';
import 'package:suspension_pro/views/bike_settings/settings_form_field.dart';
import 'package:suspension_pro/core/models/bike.dart';
import 'package:suspension_pro/core/models/component_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:suspension_pro/core/models/fork.dart';
import 'package:suspension_pro/core/models/shock.dart';
import 'package:suspension_pro/core/services/db_service.dart';

class SettingDetails extends StatefulWidget {
  SettingDetails({this.name, this.bike, this.fork, this.shock, this.frontTire, this.rearTire, this.notes});

  final String? name, frontTire, rearTire, notes;
  final Bike? bike;
  final ComponentSetting? fork, shock;

  @override
  _SettingDetailsState createState() => _SettingDetailsState();
}

class _SettingDetailsState extends State<SettingDetails> {
  final _formKey = GlobalKey<FormState>();
  final db = DatabaseService();
  final _settingNameController = TextEditingController();
  late String _hscFork,
      _lscFork,
      _hsrFork,
      _lsrFork,
      _springRateFork,
      _frontTire,
      _hscShock,
      _lscShock,
      _hsrShock,
      _lsrShock,
      _springRateShock,
      _rearTire;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    String? $setting = widget.name;
    ComponentSetting? $fork = widget.fork;
    ComponentSetting? $shock = widget.shock;
    _settingNameController.text = $setting != null ? $setting : '';
    _notesController.text = widget.notes ?? '';
    _hscFork = $fork?.hsc ?? '';
    _lscFork = $fork?.lsc ?? '';
    _hsrFork = $fork?.hsr ?? '';
    _lsrFork = $fork?.lsr ?? '';
    _springRateFork = $fork?.springRate ?? '';
    _frontTire = widget.frontTire ?? '';
    _hscShock = $shock?.hsc ?? '';
    _lscShock = $shock?.lsc ?? '';
    _hsrShock = $shock?.hsr ?? '';
    _lsrShock = $shock?.lsr ?? '';
    _springRateShock = $shock?.springRate ?? '';
    _rearTire = widget.rearTire ?? '';
  }

  Future<bool> _updateSetting(bikeId, BuildContext context) {
    Navigator.pop(context);
    // TODO: Update in HIVE first - prob have to create a 'settings' box
    db.updateSetting(bikeId, _settingNameController.text, _hscFork, _lscFork, _hsrFork, _lsrFork, _springRateFork,
        _hscShock, _lscShock, _hsrShock, _lsrShock, _springRateShock, _frontTire, _rearTire, _notesController.text);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    Fork? $fork = widget.bike != null ? widget.bike!.fork : null;
    Shock? $shock = widget.bike != null ? widget.bike!.shock : null;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      validator: (_settingNameController) {
                        if (_settingNameController == null || _settingNameController.isEmpty)
                          return 'Please add a setting title';
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
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(children: <Widget>[
                          SizedBox(
                            child: Text($fork != null ? $fork.brand + ' ' + $fork.model : 'No fork saved'),
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
                          SizedBox(height: 10),
                          SettingsFormField(
                              label: 'HSC',
                              value: widget.fork?.hsc,
                              onValueChange: (val) => setState(() => _hscFork = val)),
                          SettingsFormField(
                              label: 'LSC',
                              value: widget.fork?.lsc,
                              onValueChange: (val) => setState(() => _lscFork = val)),
                          SettingsFormField(
                              label: 'HSR',
                              value: widget.fork?.hsr,
                              onValueChange: (val) => setState(() => _hsrFork = val)),
                          SettingsFormField(
                              label: 'LSR',
                              value: widget.fork?.lsr,
                              onValueChange: (val) => setState(() => _lsrFork = val)),
                          SettingsFormField(
                              label: 'SPRING / PSI',
                              value: widget.fork?.springRate,
                              onValueChange: (val) => setState(() => _springRateFork = val)),
                          SettingsFormField(
                              label: 'FRONT TIRE PSI',
                              value: widget.frontTire,
                              onValueChange: (val) => setState(() => _frontTire = val)),
                        ]),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              child: Text($shock != null ? $shock.brand + ' ' + $shock.model : 'No shock saved'),
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
                            SizedBox(height: 10),
                            SettingsFormField(
                                label: 'HSC',
                                value: widget.shock?.hsc,
                                onValueChange: (val) => setState(() => _hscShock = val)),
                            SettingsFormField(
                                label: 'LSC',
                                value: widget.shock?.lsc,
                                onValueChange: (val) => setState(() => _lscShock = val)),
                            SettingsFormField(
                                label: 'HSR',
                                value: widget.shock?.hsr,
                                onValueChange: (val) => setState(() => _hsrShock = val)),
                            SettingsFormField(
                                label: 'LSR',
                                value: widget.shock?.lsr,
                                onValueChange: (val) => setState(() => _lsrShock = val)),
                            SettingsFormField(
                                label: 'SPRING / PSI',
                                value: widget.shock?.springRate,
                                onValueChange: (val) => setState(() => _springRateShock = val)),
                            SettingsFormField(
                                label: 'REAR TIRE PSI',
                                value: widget.rearTire,
                                onValueChange: (val) => setState(() => _rearTire = val)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 10),
                  Theme(
                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      shape: Border.all(color: Colors.transparent),
                      title: Text('Notes'),
                      children: [
                        TextField(
                          minLines: 1,
                          maxLines: 4,
                          controller: _notesController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(6),
                            hintText: 'Add custom notes for this setting',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
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
      
    );
  }
}
