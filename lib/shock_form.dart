import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

class ShockForm extends StatefulWidget {
  ShockForm({@required this.uid, this.bike, this.shock, this.shockCallback});

  final uid;
  final String bike;
  final Map shock;
  final Function(Map val) shockCallback;

  @override
  _ShockFormState createState() => _ShockFormState();
}

class _ShockFormState extends State<ShockForm> {
  final db = DatabaseService();
  final _yearController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _strokeController = TextEditingController();
  final _spacersController = TextEditingController();

  @override
  void initState() {
    super.initState();
      var $shock = widget.shock;
      _yearController.text = $shock != null ? $shock['year'].toString() : '';
      _brandController.text = $shock != null ? $shock['brand'] ?? '' : '';
      _modelController.text = $shock != null ? $shock['model'] ?? '' : '';
      _spacersController.text = $shock != null ? $shock['spacers'].toString() : '';
      _strokeController.text = $shock != null ? $shock['stroke'] : '';
  }

  @override
  void dispose() {
    _strokeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _spacersController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<bool> _updateShock(bike, BuildContext context) {
    Navigator.pop(context);
    db.updateShock(
      widget.uid, widget.bike, _yearController.text, _strokeController.text, 
      _brandController.text, _modelController.text, _spacersController.text
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          widget.shock != null ? 
            Image.asset('assets/fox-dpx2.png', height: 150)
          : Padding(
              padding: EdgeInsets.all(10),
              child: Text('Shock Details')
            ),
          CupertinoTextField(
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            padding: EdgeInsets.all(10),
            placeholder: 'Shock Year',
            controller: _yearController,
            keyboardType: TextInputType.text
          ),
          CupertinoTextField(
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            padding: EdgeInsets.all(10),
            placeholder: 'Shock Brand',
            controller: _brandController,
            keyboardType: TextInputType.text
          ),
          CupertinoTextField(
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            padding: EdgeInsets.all(10),
            placeholder: 'Shock Model',
            controller: _modelController,
            keyboardType: TextInputType.text
          ),
          CupertinoTextField(
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            padding: EdgeInsets.all(10),
            placeholder: 'Shock Stroke (ex: 210x52.5)',
            controller: _strokeController,
            keyboardType: TextInputType.text
          ),
          CupertinoTextField(
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            padding: EdgeInsets.all(10),
            placeholder: 'Shock Volume Spacers', 
            controller: _spacersController,
            keyboardType: TextInputType.text
          ),
          SizedBox(height: 30),
          widget.bike != null ? Container(
            padding: EdgeInsets.only(left: 80, right: 80),
            child: CupertinoButton(
              disabledColor: CupertinoColors.quaternarySystemFill,
              color: CupertinoColors.activeBlue,
              child: Text('Save', style: TextStyle(color: Colors.white)),
              // TODO: Set a validation check and disable the save button unless valid.
              onPressed: ()=> _updateShock(widget.bike, context)
            ),
          ) :
          Container(
            padding: EdgeInsets.only(left: 80, right: 80),
            child: CupertinoButton(
              disabledColor: CupertinoColors.quaternarySystemFill,
              color: CupertinoColors.activeBlue,
              child: Text('Save', style: TextStyle(color: Colors.white)),
              // TODO: Set a validation check and disable the save button unless valid.
              // Passing the shock form values back to the BikeForm state.
              onPressed: () => widget.shockCallback({
                'year': _yearController.text,
                'brand': _brandController.text,
                'model': _modelController.text,
                'spacers': _spacersController.text,
                'stroke': _strokeController.text
              })
            ),
          ),
        ],
      ),
    );
  }
}