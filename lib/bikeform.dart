import 'package:flutter/material.dart';
import 'fork_form.dart';
import 'shock_form.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class BikeForm extends StatefulWidget {
  BikeForm({Key? key, @required this.uid, this.bike, this.fork, this.shock})
      : super(key: key);
  final uid;
  final bike;
  Map? fork;
  Map? shock;

  @override
  _BikeFormState createState() => _BikeFormState();
}

class _BikeFormState extends State<BikeForm> {
  final _formKey = GlobalKey<FormState>();
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
      if (val['year'] == '' && val['brand'] == '' && val['model'] == '') {
        widget.shock = null;
      } else
        widget.shock = val;
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
      color: CupertinoColors.white,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: TextFormField(
                      autofocus: true,
                      validator: (_bikeController) {
                        if (_bikeController == null || _bikeController.isEmpty)
                          return 'Please add a bike name';
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.pedal_bike_sharp,
                            size: 28, color: Colors.blue),
                        isDense: true,
                        filled: true,
                        hoverColor: Colors.blue.shade100,
                        border: OutlineInputBorder(),
                        hintText: 'Add Bike Name',
                      ),
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      controller: _bikeController,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  Visibility(
                    visible: _isVisibleFork,
                    maintainState: true,
                    child: ForkForm(
                        uid: widget.uid,
                        bikeId: widget.bike,
                        fork: widget.fork,
                        forkCallback: (val) => showForkForm(val)),
                  ),
                  Visibility(
                    maintainState: true,
                    visible: _isVisibleShock,
                    child: ShockForm(
                        uid: widget.uid,
                        bike: widget.bike,
                        shock: widget.shock,
                        shockCallback: (val) =>
                            showShockForm(widget.fork, val)),
                  ),
                  SizedBox(height: 20),
                  widget.bike != null
                      ? CupertinoButton(
                          color: CupertinoColors.quaternaryLabel,
                          child: Text('Save'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _addUpdateBike(widget.fork, widget.shock);
                            }
                          })
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
