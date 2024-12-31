import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import 'package:flutter/cupertino.dart';

class ShockForm extends StatefulWidget {
  ShockForm({this.bikeId, this.shock, this.shockCallback});

  final String? bikeId;
  final Map? shock;
  final Function(Map val)? shockCallback;

  @override
  _ShockFormState createState() => _ShockFormState();
}

class _ShockFormState extends State<ShockForm> {
  final _formKey = GlobalKey<FormState>();
  final db = DatabaseService();
  final _yearController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _strokeController = TextEditingController();
  final _spacersController = TextEditingController();
  final _serialNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var $shock = widget.shock;
    _yearController.text = $shock?['year'] ?? '';
    _brandController.text = $shock?['brand'] ?? '';
    _modelController.text = $shock?['model'] ?? '';
    _spacersController.text = $shock?['spacers'] ?? '';
    _strokeController.text = $shock?['stroke'] ?? '';
    _serialNumberController.text = $shock?['serial'] ?? '';
  }

  @override
  void dispose() {
    _strokeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _spacersController.dispose();
    _yearController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  Future<bool> _updateShock(bike, BuildContext context) {
    Navigator.pop(context);
    db.updateShock(
        widget.bikeId!,
        _yearController.text,
        _strokeController.text,
        _brandController.text,
        _modelController.text,
        _spacersController.text,
        _serialNumberController.text);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Material(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(2),
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: CupertinoColors.inactiveGray.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/shock.png')),
                ),
                if (widget.shock == null)
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                              'Leave shock form details blank to \nsave without a rear shock',
                              textAlign: TextAlign.center),
                        ],
                      )),
                TextFormField(
                    // validator: (_yearController) {
                    //   if (_yearController == null || _yearController.isEmpty)
                    //     return 'Please enter shock year';
                    //   return null;
                    // },
                    decoration: _decoration('Shock Year'),
                    controller: _yearController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.number),
                TextFormField(
                    // validator: (_brandController) {
                    //   if (_brandController == null || _brandController.isEmpty)
                    //     return 'Enter shock brand';
                    //   return null;
                    // },
                    decoration: _decoration('Shock Brand'),
                    controller: _brandController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    // validator: (_modelController) {
                    //   if (_modelController == null || _modelController.isEmpty)
                    //     return 'Enter shock model';
                    //   return null;
                    // },
                    decoration: _decoration('Shock Model'),
                    controller: _modelController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    decoration: _decoration('Shock Stroke (ex: 210x52.5)'),
                    controller: _strokeController,
                    keyboardType: TextInputType.text),
                TextFormField(
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    decoration: _decoration('Shock Volume Spacers'),
                    controller: _spacersController,
                    keyboardType: TextInputType.number),
                TextFormField(
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    decoration: InputDecoration(
                      hintText: 'Shock Serial Number',
                    ),
                    controller: _serialNumberController,
                    keyboardType: TextInputType.text),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.only(left: 80, right: 80),
                  child: CupertinoButton(
                      disabledColor: CupertinoColors.quaternarySystemFill,
                      color: CupertinoColors.activeBlue,
                      child:
                          Text('Save', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.bikeId != ''
                              ? _updateShock(widget.bikeId, context)
                              : widget.shockCallback!({
                                  'year': _yearController.text,
                                  'brand': _brandController.text,
                                  'model': _modelController.text,
                                  'spacers': _spacersController.text,
                                  'stroke': _strokeController.text,
                                  'serial': _serialNumberController.text,
                                });
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(fontSize: 18, color: Colors.grey[400]),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      fillColor: Colors.white,
      filled: true,
      border: UnderlineInputBorder(borderRadius: BorderRadius.zero),
    );
  }
}
