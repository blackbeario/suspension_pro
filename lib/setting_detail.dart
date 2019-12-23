import 'package:flutter/material.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

class SettingDetails extends StatefulWidget {
  SettingDetails({@required this.uid, @required this.setting, @required this.bike, this.fork, this.shock});

  final uid;
  final String setting;
  final String bike;
  final Map fork;
  final Map shock;

  @override
  _SettingDetailsState createState() => _SettingDetailsState();
}

class _SettingDetailsState extends State<SettingDetails> {
  final db = DatabaseService();
  final _hscForkController = TextEditingController();
  final _lscForkController = TextEditingController();
  final _hsrForkController = TextEditingController();
  final _lsrForkController = TextEditingController();
  final _springRateForkController = TextEditingController(); // Can be PSI or Coil
  final _hscShockController = TextEditingController();
  final _lscShockController = TextEditingController();
  final _hsrShockController = TextEditingController();
  final _lsrShockController = TextEditingController();
  final _springRateShockController = TextEditingController(); // Can be PSI or Coil

  @override
  void initState() {
    super.initState();
      _hscForkController.text = widget.fork['HSC'].toString();
      _lscForkController.text = widget.fork['LSC'].toString();
      _hsrForkController.text = widget.fork['HSR'].toString();
      _lsrForkController.text = widget.fork['LSR'].toString();
      _springRateForkController.text = widget.fork['springRate'].toString();
      _hscShockController.text = widget.shock['HSC'].toString();
      _lscShockController.text = widget.shock['LSC'].toString();
      _hsrShockController.text = widget.shock['HSR'].toString();
      _lsrShockController.text = widget.shock['LSR'].toString();
      _springRateShockController.text = widget.shock['springRate'].toString();
  }

  @override
  void dispose() {
    _hscForkController.dispose();
    _lscForkController.dispose();
    _hsrForkController.dispose();
    _lsrForkController.dispose();
    _springRateForkController.dispose();
    _hscShockController.dispose();
    _lscShockController.dispose();
    _hsrShockController.dispose();
    _lsrShockController.dispose();
    _springRateShockController.dispose();
    super.dispose();
  }

  Future<bool> _updateSetting(bike, BuildContext context) {
    Navigator.pop(context);
    db.updateSetting(
      widget.uid, widget.setting, widget.bike, _hscForkController.text, _lscForkController.text, 
      _hsrForkController.text, _lsrForkController.text, _springRateForkController.text,
      _hscShockController.text, _lscShockController.text, 
      _hsrShockController.text, _lsrShockController.text, _springRateShockController.text
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.setting + ' / ' + widget.bike),
      ),
      child: Material(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Image.asset('assets/fox36-black.jpg', height: 50),
                      // year
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'HSC',
                          labelText: 'HSC',
                        ),
                        controller: _hscForkController,
                        keyboardType: TextInputType.text
                      ),
                      // travel
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'LSC',
                          labelText: 'LSC',
                        ),
                        controller: _lscForkController,
                        keyboardType: TextInputType.text
                      ),
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'HSR',
                          labelText: 'HSR',
                        ),
                        controller: _hsrForkController,
                        keyboardType: TextInputType.text
                      ),
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'LSR',
                          labelText: 'LSR',
                        ),
                        controller: _lsrForkController,
                        keyboardType: TextInputType.text
                      ),
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'SPRING / PSI',
                          labelText: 'SPRING / PSI',
                        ),
                        controller: _springRateForkController,
                        keyboardType: TextInputType.text
                      ),
                    ]
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Image.asset('assets/fox-dpx2.png', height: 50),
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'HSC',
                          labelText: 'HSC',
                        ),
                        controller: _hscShockController,
                        keyboardType: TextInputType.text
                      ),
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'LSC',
                          labelText: 'LSC',
                        ),
                        controller: _lscShockController,
                        keyboardType: TextInputType.text
                      ),
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'HSR',
                          labelText: 'HSR',
                        ),
                        controller: _lscShockController,
                        keyboardType: TextInputType.text
                      ),
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'LSR',
                          labelText: 'LSR',
                        ),
                        controller: _lscShockController,
                        keyboardType: TextInputType.text
                      ),
                      TextField(
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'SPRING / PSI',
                          labelText: 'SPRING / PSI',
                        ),
                        controller: _springRateShockController,
                        keyboardType: TextInputType.text
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            CupertinoButton(
              // padding: EdgeInsets.all(10),
              color: CupertinoColors.quaternaryLabel,
              child: Text('Save'),
              onPressed: () => 
                _updateSetting(widget.bike, context)
            ),
            Expanded(child: Container())
          ],
        ),
      ),
    );
  }
}