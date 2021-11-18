import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'fork_form.dart';
import 'models/user.dart';
import 'shock_form.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class BikeForm extends StatefulWidget {
  BikeForm({Key? key, @required this.uid, this.bike}) : super(key: key);
  final uid;
  final bike;

  @override
  _BikeFormState createState() => _BikeFormState();
}

class _BikeFormState extends State<BikeForm> {
  final db = DatabaseService();
  final _bikeController = TextEditingController();
  bool _isVisibleForkForm = false;
  bool _isVisibleShockForm = false;
  String _enteredText = '';
  late Map? fork = {};
  late Map? shock = {};

  void showForkForm(forkValues) async {
    setState(() {
      fork = forkValues;
      _isVisibleForkForm = !_isVisibleForkForm;
      _isVisibleShockForm = !_isVisibleShockForm;
    });
  }

  void showShockForm(fork, shockValues) {
    setState(() {
      if (shockValues['year'] == '' &&
          shockValues['brand'] == '' &&
          shockValues['model'] == '') {
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
    _bikeController.text = widget.bike != null ? widget.bike : '';
  }

  @override
  void dispose() {
    _bikeController.dispose();
    super.dispose();
  }

  Future<bool> _addUpdateBike() {
    Navigator.pop(context);
    db.addUpdateBike(widget.uid, _bikeController.text, fork, shock);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
        stream: db.streamUser(widget.uid),
        builder: (context, snapshot) {
          var myUser = snapshot.data;
          if (myUser == null) {
            return Center(child: CupertinoActivityIndicator(animating: true));
          }

          return CupertinoPageScaffold(
            resizeToAvoidBottomInset: true,
            navigationBar: CupertinoNavigationBar(
              padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 5),
              middle: Text(widget.bike != null ? widget.bike.id : 'Add Bike'),
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
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: TextFormField(
                          enabled: !_isVisibleShockForm,
                          autofocus: false,
                          decoration: InputDecoration(
                              suffixIcon: Icon(Icons.pedal_bike_sharp,
                                  size: 24,
                                  color: CupertinoColors.activeBlue
                                      .withOpacity(0.5)),
                              isDense: true,
                              filled: true,
                              hoverColor: Colors.blue.shade100,
                              semanticCounterText: 'Must enter 3 chars',
                              counterText: _bikeController.text.length < 6
                                  ? '${_enteredText.length.toString()} character(s)'
                                  : null,
                              border: OutlineInputBorder(),
                              hintText: 'Add Bike Name',
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)),
                              errorText: _bikeController.text.length < 6
                                  ? 'Please enter at least 6 characters'
                                  : null,
                              errorStyle: TextStyle(color: Colors.grey[700])),
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[700]),
                          controller: _bikeController,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            setState(() {
                              _enteredText = value;
                              _checkFieldLength(value, 6);
                            });
                          },
                        ),
                      ),
                      Visibility(
                        visible: _isVisibleForkForm,
                        maintainState: true,
                        child: ForkForm(
                            uid: widget.uid,
                            bikeId: widget.bike,
                            fork: fork,
                            forkCallback: (val) => showForkForm(val)),
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
                        child: ShockForm(
                            uid: widget.uid,
                            bike: widget.bike,
                            shock: shock,
                            shockCallback: (val) => showShockForm(fork, val)),
                      ),
                      SizedBox(height: 20),
                      widget.bike != null
                          ? CupertinoButton(
                              color: CupertinoColors.quaternaryLabel,
                              child: Text('Save'),
                              onPressed: _bikeController.text.isNotEmpty
                                  ? () async {
                                      await _addUpdateBike();
                                    }
                                  : null)
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _checkFieldLength(String value, int requirement) {
    if (value.length < requirement) {
      _isVisibleForkForm = false;
    } else
      _isVisibleForkForm = true;
  }
}
