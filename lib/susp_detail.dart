import 'package:flutter/material.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

class SuspensionDetails extends StatefulWidget {
  SuspensionDetails({@required this.uid, @required this.bike, this.fork, this.shock, @required this.type});

  final uid;
  final String bike;
  final Map fork;
  final Map shock;
  final String type;

  @override
  _SuspensionDetailsState createState() => _SuspensionDetailsState();
}

class _SuspensionDetailsState extends State<SuspensionDetails> {
  final db = DatabaseService();
  final _yearController = TextEditingController();
  final _travelController = TextEditingController();
  final _damperController = TextEditingController();
  final _offsetController = TextEditingController();
  final _wheelsizeController = TextEditingController();
  final _strokeController = TextEditingController();

  @override
  void initState() {
    super.initState();
      _yearController.text = widget.type != 'shock' ? widget.fork['year'].toString() : widget.shock['year'].toString();
      _travelController.text = widget.type != 'shock' ? widget.fork['travel'].toString() : widget.shock['travel'].toString();
      _damperController.text = widget.type != 'shock' ? widget.fork['damper'] : '';
      _offsetController.text = widget.type != 'shock' ? widget.fork['offset'].toString() : '';
      _wheelsizeController.text = widget.type != 'shock' ? widget.fork['wheelsize'].toString() : '';
      _strokeController.text = widget.type == 'shock' ? widget.shock['stroke'] : '';
  }

  @override
  void dispose() {
    _yearController.dispose();
    _travelController.dispose();
    _damperController.dispose();
    _offsetController.dispose();
    _wheelsizeController.dispose();
    _strokeController.dispose();
    super.dispose();
  }

  Future<bool> _updateFork(bike, BuildContext context) {
    Navigator.pop(context);
    db.updateFork(
      widget.uid, widget.bike, _yearController.text, _travelController.text, 
      _damperController.text, _offsetController.text, _wheelsizeController.text
    );
    return Future.value(false);
  }

  Future<bool> _updateShock(bike, BuildContext context) {
    Navigator.pop(context);
    db.updateShock(
      widget.uid, widget.bike, _yearController.text, _travelController.text, 
      _strokeController.text
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.type != 'shock' ? 
          widget.fork['brand'] + ' ' + widget.fork['model'] :
          widget.shock['brand'] + ' ' + widget.shock['model']
        ),
      ),
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            widget.type != 'shock' ? Column(
              children: <Widget>[
                Image.asset('assets/fox36-black.jpg', height: 250),
                // year
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'year',
                    labelText: 'year',
                  ),
                  controller: _yearController,
                  keyboardType: TextInputType.text
                ),
                // travel
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'travel',
                    labelText: 'travel',
                  ),
                  controller: _travelController,
                  keyboardType: TextInputType.text
                ),
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'damper',
                    labelText: 'damper',
                  ),
                  controller: _damperController,
                  keyboardType: TextInputType.text
                ),
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'offset',
                    labelText: 'offset',
                  ),
                  controller: _offsetController,
                  keyboardType: TextInputType.text
                ),
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'wheel size',
                    labelText: 'wheel size',
                  ),
                  controller: _wheelsizeController,
                  keyboardType: TextInputType.text
                ),
              ]
            )
          : Column(
              children: <Widget>[
                Image.asset('assets/fox-dpx2.png', height: 250),
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'year',
                    labelText: 'year',
                  ),
                  controller: _yearController,
                  keyboardType: TextInputType.text
                ),
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'stroke',
                    labelText: 'stroke',
                  ),
                  controller: _strokeController,
                  keyboardType: TextInputType.text
                ),
              ],
            ),
            SizedBox(height: 20),
            CupertinoButton(
              // padding: EdgeInsets.all(10),
              color: CupertinoColors.quaternaryLabel,
              child: Text('Save'),
              onPressed: () => 
                widget.type != 'shock' ? _updateFork(widget.bike, context) : _updateShock(widget.bike, context)
            ),
            Expanded(child: Container())
          ],
        ),
      ),
    );
  }
}