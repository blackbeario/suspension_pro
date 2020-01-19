import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

class ForkForm extends StatefulWidget {
  ForkForm({@required this.uid, this.bike, this.fork, this.forkCallback});

  final uid;
  final String bike;
  final Map fork;
  final Function(Map val) forkCallback;

  @override
  _ForkFormState createState() => _ForkFormState();
}

class _ForkFormState extends State<ForkForm> {
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

  @override
  void initState() {
    super.initState();
      var $fork = widget.fork;
      _yearController.text = $fork != null ? $fork['year'] : '';
      _brandController.text = $fork != null ? $fork['brand'] : '';
      _modelController.text = $fork != null ? $fork['model'] : '';
      _travelController.text = $fork != null ? $fork['travel'] : '';
      _damperController.text = $fork != null ? $fork['damper'] : '';
      _offsetController.text = $fork != null ? $fork['offset'] : '';
      _wheelsizeController.text = $fork != null ? $fork['wheelsize'] : '';
      _spacingController.text = $fork != null ? $fork['spacing'] : '';
      _spacersController.text = $fork != null ? $fork['spacers'] : '';
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
      widget.uid, widget.bike, _yearController.text, _travelController.text, _damperController.text, _offsetController.text, 
      _wheelsizeController.text, _brandController.text, _modelController.text, _spacersController.text, _spacingController.text
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Column(
              children: <Widget>[
                widget.fork != null ? 
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Image.asset('assets/fox36-black.jpg', height: 150) 
                  )
                : Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Fork Details')
                  ),
                CupertinoTextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  padding: EdgeInsets.all(10),
                  placeholder: 'Fork Year',                  
                  controller: _yearController,
                  keyboardType: TextInputType.text
                ),
                CupertinoTextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  padding: EdgeInsets.all(10),
                  placeholder: 'Fork Brand', 
                  controller: _brandController,
                  keyboardType: TextInputType.text
                ),
                CupertinoTextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  padding: EdgeInsets.all(10),
                  placeholder: 'Fork Model',
                  controller: _modelController,
                  keyboardType: TextInputType.text
                ),
                CupertinoTextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  padding: EdgeInsets.all(10),
                  placeholder: 'Fork Travel mm (130, 150...)',
                  controller: _travelController,
                  keyboardType: TextInputType.text
                ),
                CupertinoTextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  padding: EdgeInsets.all(10),
                  placeholder: 'Fork Damper',
                  controller: _damperController,
                  keyboardType: TextInputType.text
                ),
                CupertinoTextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  padding: EdgeInsets.all(10),
                  placeholder: 'Fork Offset mm (44, 51...)',
                  controller: _offsetController,
                  keyboardType: TextInputType.text
                ),
                CupertinoTextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  padding: EdgeInsets.all(10),
                  placeholder: 'Wheel Size inches (26, 27.5, 29...)',
                  controller: _wheelsizeController,
                  keyboardType: TextInputType.text
                ),
                CupertinoTextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  padding: EdgeInsets.all(10),
                  placeholder: 'Fork Volume Spacers',
                  controller: _spacersController,
                  keyboardType: TextInputType.text
                ),
                CupertinoTextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  padding: EdgeInsets.all(10),
                  placeholder: 'Fork Spacing mm (135, 142, 148...)',
                  controller: _spacingController,
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
                    onPressed: ()=> _updateFork(widget.bike, context)
                  ),
                ) : 
                Container(
                  padding: EdgeInsets.only(left: 80, right: 80),
                  child: CupertinoButton(
                    disabledColor: CupertinoColors.quaternarySystemFill,
                    color: CupertinoColors.activeBlue,
                    child: Text('Continue', style: TextStyle(color: Colors.white)),
                    // TODO: Set a validation check and disable the save button unless valid.
                    // Passing the fork form values back to the BikeForm state.
                    onPressed: () => widget.forkCallback({
                        'year': _yearController.text,
                        'brand': _brandController.text,
                        'model': _modelController.text,
                        'travel': _travelController.text,
                        'damper': _damperController.text,
                        'offset': _offsetController.text,
                        'wheelsize': _wheelsizeController.text,
                        'spacers': _spacersController.text,
                        'spacing': _spacingController.text
                    })
                  ),
                ),
              ]
            ),
        ],
      ),
    );
  }
}