import 'package:flutter/material.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

class BikeForm extends StatefulWidget {
  BikeForm({Key key, @required this.uid, this.bike}) : super(key: key);
  final uid;
  final String bike;

  @override
  _BikeFormState createState() => _BikeFormState();
}

class _BikeFormState extends State<BikeForm> {
  final db = DatabaseService();
  final _bikeController = TextEditingController();

    @override
  void initState() {
    super.initState();
      _bikeController.text = widget.bike ?? '';
  }

  @override
  void dispose() {
    _bikeController.dispose();
    super.dispose();
  }

  Future<bool> _updateBike(BuildContext context) {
    Navigator.pop(context);
    db.updateBike(widget.uid, _bikeController.text);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add Bike'),
      ),
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                // year
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'bike',
                    labelText: 'bike',
                  ),
                  controller: _bikeController,
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
                _updateBike(context)
            ),
            Expanded(child: Container())
          ],
        ),
      ),
    );
  }
}