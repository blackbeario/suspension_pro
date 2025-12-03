import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/component_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:ridemetrx/features/bikes/domain/models/fork.dart';
import 'package:ridemetrx/features/bikes/domain/models/shock.dart';
import 'package:ridemetrx/features/bikes/presentation/widgets/settings_form_field.dart';
import 'package:ridemetrx/features/bikes/presentation/view_models/setting_detail_view_model.dart';

class SettingDetails extends ConsumerStatefulWidget {
  SettingDetails({this.name, this.bike, this.fork, this.shock, this.frontTire, this.rearTire, this.notes});

  final String? name, frontTire, rearTire, notes;
  final Bike? bike;
  final ComponentSetting? fork, shock;

  @override
  ConsumerState<SettingDetails> createState() => _SettingDetailsState();
}

class _SettingDetailsState extends ConsumerState<SettingDetails> {
  final _formKey = GlobalKey<FormState>();
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

  // Track the original setting ID when editing (null for new settings)
  String? _originalSettingId;

  @override
  void initState() {
    super.initState();
    String? $setting = widget.name;
    ComponentSetting? $fork = widget.fork;
    ComponentSetting? $shock = widget.shock;

    // Store the original ID when editing an existing setting
    _originalSettingId = $setting;

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

  Future _addUpdateSetting(bikeId, BuildContext context) async {
    final viewModel = ref.read(settingDetailViewModelProvider.notifier);

    await viewModel.saveSetting(
      bikeId: bikeId,
      settingName: _settingNameController.text,
      originalSettingId: _originalSettingId,
      hscFork: _hscFork,
      lscFork: _lscFork,
      hsrFork: _hsrFork,
      lsrFork: _lsrFork,
      springRateFork: _springRateFork,
      frontTire: _frontTire,
      hscShock: _hscShock,
      lscShock: _lscShock,
      hsrShock: _hsrShock,
      lsrShock: _lsrShock,
      springRateShock: _springRateShock,
      rearTire: _rearTire,
      notes: _notesController.text,
    );

    Navigator.pop(context);
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
                      suffixIcon: Icon(Icons.settings, size: 24, color: CupertinoColors.activeBlue.withValues(alpha: 0.5)),
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
                            await _addUpdateSetting(widget.bike!.id, context);
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
