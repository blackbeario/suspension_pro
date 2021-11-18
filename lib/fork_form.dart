import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

class ForkForm extends StatefulWidget {
  ForkForm({required this.uid, this.bikeId, this.fork, this.forkCallback});

  final uid;
  final String? bikeId;
  final Map? fork;
  final Function(Map val)? forkCallback;

  @override
  _ForkFormState createState() => _ForkFormState();
}

class _ForkFormState extends State<ForkForm> {
  final _formKey = GlobalKey<FormState>();
  final db = DatabaseService();
  final _yearController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _travelController = TextEditingController();
  final _damperController = TextEditingController();
  final _offsetController = TextEditingController();
  final _wheelsizeController = TextEditingController();
  final _spacersController = TextEditingController();
  final _spacingController = TextEditingController();
  bool buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    var $fork = widget.fork;
    _yearController.text = $fork?['year'] ?? '';
    _brandController.text = $fork?['brand'] ?? '';
    _modelController.text = $fork?['model'] ?? '';
    _travelController.text = $fork?['travel'] ?? '';
    _damperController.text = $fork?['damper'] ?? '';
    _offsetController.text = $fork?['offset'] ?? '';
    _wheelsizeController.text = $fork?['wheelsize'] ?? '';
    _spacingController.text = $fork?['spacing'] ?? '';
    _spacersController.text = $fork?['spacers'] ?? '';
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _travelController.dispose();
    _damperController.dispose();
    _offsetController.dispose();
    _wheelsizeController.dispose();
    _spacingController.dispose();
    _spacersController.dispose();
    super.dispose();
  }

  Future<bool> _updateFork(bike, BuildContext context) {
    Navigator.pop(context);
    db.updateFork(
        widget.uid,
        widget.bikeId!,
        _yearController.text,
        _travelController.text,
        _damperController.text,
        _offsetController.text,
        _wheelsizeController.text,
        _brandController.text,
        _modelController.text,
        _spacersController.text,
        _spacingController.text);
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
              children: [
                Container(
                    width: double.infinity,
                    // padding: EdgeInsets.all(20),
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
                        child: Image.asset('assets/fork.png'))),
                TextFormField(
                    validator: (_yearController) {
                      if (_yearController == null || _yearController.isEmpty)
                        return 'Please enter fork year';
                      return null;
                    },
                    decoration: _decoration('Fork Year'),
                    controller: _yearController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    validator: (_brandController) {
                      if (_brandController == null || _brandController.isEmpty)
                        return 'Enter fork brand';
                      return null;
                    },
                    decoration: _decoration('Fork Brand'),
                    controller: _brandController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    validator: (_modelController) {
                      if (_modelController == null || _modelController.isEmpty)
                        return 'Enter fork model';
                      return null;
                    },
                    decoration: _decoration('Fork Model'),
                    controller: _modelController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    validator: (_travelController) {
                      if (_travelController == null ||
                          _travelController.isEmpty) return 'Enter fork travel';
                      return null;
                    },
                    decoration:
                        _decoration('Fork Travel mm (130, 150, 170, 200)'),
                    controller: _travelController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    decoration: _decoration('Fork Damper'),
                    controller: _damperController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    decoration: _decoration('Fork Offset mm (44, 51)'),
                    controller: _offsetController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    validator: (_wheelsizeController) {
                      if (_wheelsizeController == null ||
                          _wheelsizeController.isEmpty)
                        return 'Enter wheel size';
                      return null;
                    },
                    decoration: _decoration('Wheel Size (26, 27.5, 29)'),
                    controller: _wheelsizeController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    decoration: _decoration('Fork Volume Spacers'),
                    controller: _spacersController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                TextFormField(
                    decoration:
                        _decoration('Fork Spacing mm (100, 110, 115...)'),
                    controller: _spacingController,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    keyboardType: TextInputType.text),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: CupertinoButton(
                    disabledColor: CupertinoColors.quaternarySystemFill,
                    color: CupertinoColors.activeBlue,
                    child:
                        widget.bikeId != null ? Text('Save') : Text('Continue'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.bikeId != null
                            ? _updateFork(widget.bikeId, context)
                            : widget.forkCallback!({
                                'year': _yearController.text,
                                'brand': _brandController.text,
                                'model': _modelController.text,
                                'travel': _travelController.text,
                                'damper': _damperController.text,
                                'offset': _offsetController.text,
                                'wheelsize': _wheelsizeController.text,
                                'spacers': _spacersController.text,
                                'spacing': _spacingController.text
                              });
                      }
                    },
                  ),
                ),
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
