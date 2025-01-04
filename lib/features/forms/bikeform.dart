import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/models/fork.dart';
import 'package:suspension_pro/models/shock.dart';
import 'package:suspension_pro/services/db_service.dart';
import 'fork_form.dart';
import 'shock_form.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class BikeForm extends StatefulWidget {
  BikeForm({Key? key, this.bike}) : super(key: key);
  final Bike? bike;

  @override
  _BikeFormState createState() => _BikeFormState();
}

class _BikeFormState extends State<BikeForm> {
  final _formKey = GlobalKey<FormState>();
  final yearNode = FocusNode();
  final modelNode = FocusNode();
  final yearKey = GlobalKey<FormFieldState>();
  final modelKey = GlobalKey<FormFieldState>();
  
  final db = DatabaseService();
  final _yearModelController = TextEditingController();
  final _bikeController = TextEditingController();
  bool _isVisibleForkForm = false;
  bool _isVisibleShockForm = false;
  String _enteredText = '';
  late Fork? fork;
  late Shock? shock;

  void showForkForm(forkValues) async {
    setState(() {
      fork = forkValues;
      _isVisibleForkForm = !_isVisibleForkForm;
      _isVisibleShockForm = !_isVisibleShockForm;
    });
  }

  void showShockForm(fork, shockValues) {
    setState(() {
      if (shockValues['year'] == '' && shockValues['brand'] == '' && shockValues['model'] == '') {
        shock = null;
      } else {
        shock = shockValues;
      }
      _isVisibleShockForm = !_isVisibleShockForm;
      _addUpdateBike();
    });
  }

  @override
  void initState() {
    super.initState();
    _yearModelController.text = _getModelYear();
    _bikeController.text = _getBikeName();
    yearNode.addListener(() {
      if (!yearNode.hasFocus) {
        yearKey.currentState!.validate();
      }
    });
    modelNode.addListener(() {
      if (!modelNode.hasFocus) {
        modelKey.currentState!.validate();
      }
    });
  }

  @override
  void dispose() {
    _bikeController.dispose();
    _yearModelController.dispose();
    super.dispose();
  }

  Future<bool> _addUpdateBike() async {
    Navigator.pop(context);
    final box = await Hive.openBox('bikes');
    final bike = Bike(id: _bikeController.text, yearModel: int.parse(_yearModelController.text), fork: fork, shock: shock);
    box.put(_bikeController.text, bike);
    print(box.get(_bikeController.text));

    db.addUpdateBike(bike);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 5),
        middle: Text(widget.bike != null ? widget.bike!.id : 'Add Bike'),
      ),
      child: Material(
        color: CupertinoColors.white,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    SizedBox(
                    width: 110,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: TextFormField(
                          key: yearKey,
                          focusNode: yearNode,
                          enabled: !_isVisibleShockForm,
                          autofocus: false,
                          decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              hoverColor: Colors.blue.shade100,
                              helper: _yearModelController.text.length < 4 ? Text('4 digits') : SizedBox(height: 20),
                              border: OutlineInputBorder(),
                              hintText: 'Year',
                              focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                              errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                              // errorText: _yearModelController.text.length < 4 ? '4 digits' : '√',
                              errorStyle: TextStyle(color: Colors.grey[700])),
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          controller: _yearModelController,
                          keyboardType: TextInputType.text,
                          validator: (_yearModelController) {
                            if (_yearModelController == null || _yearModelController.isEmpty)
                              return 'Enter year';
                            return null;
                          },
                          // maxLength: 4,
                          onChanged: (value) {
                            setState(() {
                              _enteredText = value;
                              _checkFieldLength(value, 4);
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: TextFormField(
                          key: modelKey,
                          focusNode: modelNode,
                          enabled: !_isVisibleShockForm,
                          autofocus: false,
                          decoration: InputDecoration(
                              suffixIcon: _bikeController.text.length < 6 ?  Icon(Icons.pedal_bike_sharp,
                                  size: 24, color: CupertinoColors.activeBlue.withOpacity(0.5)) : Icon(Icons.check, color: Colors.green),
                              isDense: true,
                              filled: true,
                              hoverColor: Colors.blue.shade100,
                              helper: _bikeController.text.length < 6 ? Text('Minimum 6 characters') : SizedBox(height: 20),
                              semanticCounterText: 'Must enter 3 chars',
                              counterText: _bikeController.text.length < 6
                                  ? '${_enteredText.length.toString()} character(s)'
                                  : null,
                              border: OutlineInputBorder(),
                              hintText: 'Bike Model',
                              focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                              errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                              // errorText: _bikeController.text.length < 6 ? 'Minimum 6 characters' : null,
                              errorStyle: TextStyle(color: Colors.grey[700])),
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          controller: _bikeController,
                          keyboardType: TextInputType.text,
                          validator: (_bikeController) {
                            if (_bikeController == null || _bikeController.isEmpty)
                              return 'Enter bike model';
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _enteredText = value;
                              _checkFieldLength(value, 6);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),),
                Visibility(
                  visible: _isVisibleForkForm,
                  maintainState: true,
                  child: ForkForm(bikeId: _getBikeName(), fork: fork, forkCallback: (val) => showForkForm(val)),
                ),
                Visibility(
                  child: TextButton(
                    child: Text('< back to fork'),
                    onPressed: () {
                      setState(() {
                        _isVisibleForkForm = !_isVisibleForkForm;
                        _isVisibleShockForm = !_isVisibleShockForm;
                      });
                    },
                  ),
                  visible: _isVisibleShockForm,
                ),
                Visibility(
                  maintainState: true,
                  visible: _isVisibleShockForm,
                  child:
                      ShockForm(bikeId: _getBikeName(), shock: shock, shockCallback: (val) => showShockForm(fork, val)),
                ),
                SizedBox(height: 20),
                widget.bike != null
                    ? CupertinoButton(
                        color: CupertinoColors.quaternaryLabel,
                        child: Text('Save'),
                        onPressed: _bikeController.text.isNotEmpty ? () async => await _addUpdateBike() : null)
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _checkFieldLength(String value, int requirement) {
    if (value.length < requirement) {
      _isVisibleForkForm = false;
    } else if (_bikeController.text.isNotEmpty)
      _isVisibleForkForm = true;
  }

  String _getModelYear() {
    if (widget.bike != null) {
      if (widget.bike!.yearModel != null) {
        return widget.bike!.yearModel!.toString();
      } else
        return '';
    }
    return '';
  }

  String _getBikeName() {
    if (widget.bike != null) {
      return widget.bike!.id;
    }
    return '';
  }
}
