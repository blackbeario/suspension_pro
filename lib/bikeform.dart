import 'package:flutter/material.dart';
import 'package:suspension_pro/fork_form.dart';
import 'package:suspension_pro/shock_form.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

class BikeForm extends StatefulWidget {
  BikeForm({Key key, @required this.uid, this.bike, this.fork, this.shock}) : super(key: key);
  final uid;
  final bike;
  Map fork;
  Map shock;

  @override
  _BikeFormState createState() => _BikeFormState();
}

class _BikeFormState extends State<BikeForm> {
  final db = DatabaseService();
  final _bikeController = TextEditingController();
  bool _isVisibleFork = true;
  bool _isVisibleShock = false;
  
  void showForkForm(val) {
    setState(() {
      widget.fork = val;
      _isVisibleFork = !_isVisibleFork;
      _isVisibleShock = !_isVisibleShock;
    });
  }

  void showShockForm(fork, val) {
    setState(() {
      widget.shock = val;
      print({widget.fork, widget.shock});
      _isVisibleShock = !_isVisibleShock;
      _addUpdateBike(widget.fork, widget.shock);
    });
  }

  @override
  void initState() {
    super.initState();
      _bikeController.text = widget.bike != null ? widget.bike : '';
  }

  @override
  void dispose() {
    _bikeController.dispose();
    super.dispose();
  }

  Future<bool> _addUpdateBike(fork, shock) {
    Navigator.pop(context);
    db.addUpdateBike(widget.uid, _bikeController.text, fork, shock);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.bike != null ? widget.bike.id : 'Add Bike'),
      ),
      child: Material(
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CupertinoTextField(
                  padding: EdgeInsets.all(10),
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  placeholder: widget.bike != null ? widget.bike.id : 'Bike Name',
                  showCursor: true,
                  controller: _bikeController,
                  keyboardType: TextInputType.text
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: _isVisibleFork,
                  maintainState: true,
                  child: ForkForm(uid: widget.uid, bike: widget.bike, fork: widget.fork, forkCallback: (val) {
                    showForkForm(val);
                  }),
                ),
                Visibility(
                  maintainState: true,
                  visible: _isVisibleShock,
                  child: ShockForm(uid: widget.uid, bike: widget.bike, shock: widget.shock, shockCallback: (val) => showShockForm(widget.fork, val)),
                ),
                SizedBox(height: 20),
                widget.bike != null ?
                CupertinoButton(
                  color: CupertinoColors.quaternaryLabel,
                  child: Text('Save'),
                  onPressed: () => 
                    _addUpdateBike(widget.fork, widget.shock)
                ) : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}