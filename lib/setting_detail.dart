import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suspension_pro/models/user.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:share/share.dart';

class SettingDetails extends StatefulWidget {
  SettingDetails({@required this.uid, this.setting, this.bike, this.fork, this.shock});

  final uid;
  final String setting;
  final bike;
  final Map fork;
  final Map shock;

  @override
  _SettingDetailsState createState() => _SettingDetailsState();
}

class _SettingDetailsState extends State<SettingDetails> {
  final db = DatabaseService();
  final _settingNameController = TextEditingController();
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
    var $setting = widget.setting;
    var $fork = widget.fork;
    var $shock = widget.shock;
    _settingNameController.text = $setting != null ? $setting : '';
    if ($fork != null) {
      _hscForkController.text = $fork['HSC'] ?? '';
      _lscForkController.text = $fork['LSC'] ?? '';
      _hsrForkController.text = $fork['HSR'] ?? '';
      _lsrForkController.text = $fork['LSR'] ?? '';
      _springRateForkController.text = $fork['springRate'] ?? '';
    }
    if ($shock != null) {
      _hscShockController.text = $shock['HSC'] ?? '';
      _lscShockController.text = $shock['LSC'] ?? '';
      _hsrShockController.text = $shock['HSR'] ?? '';
      _lsrShockController.text = $shock['LSR'] ?? '';
      _springRateShockController.text = $shock['springRate'] ?? '';
    }
    else {
      _hscForkController.text = '';
      _lscForkController.text = '';
      _hsrForkController.text = '';
      _lsrForkController.text = '';
      _springRateForkController.text = '';
      _hscShockController.text = '';
      _lscShockController.text = '';
      _hsrShockController.text = '';
      _lsrShockController.text = '';
      _springRateShockController.text = '';
    }
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
    _settingNameController.dispose();
    super.dispose();
  }

  Future<bool> _updateSetting(bike, BuildContext context) {
    Navigator.pop(context);
    db.updateSetting(
      widget.uid, _settingNameController.text, bike, _hscForkController.text, _lscForkController.text, 
      _hsrForkController.text, _lsrForkController.text, _springRateForkController.text,
      _hscShockController.text, _lscShockController.text, 
      _hsrShockController.text, _lsrShockController.text, _springRateShockController.text
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    var $fork = widget.bike != null ? widget.bike.fork : null;
    var $shock = widget.bike != null ? widget.bike.shock : null;
    return StreamBuilder<User>(
      stream: db.streamUser(widget.uid),
      builder: (context, snapshot) {
        var myUser = snapshot.data;
        if (myUser == null) {
          return Center(
            child: CupertinoActivityIndicator(animating: true)
          );
        }
        return CupertinoPageScaffold(
          resizeToAvoidBottomInset: true,
          navigationBar: CupertinoNavigationBar(
            middle: Text(widget.setting != null ? widget.setting : 'New Setting'),
            trailing: FlatButton.icon(
              label: Text('Share'),
              icon: Icon(CupertinoIcons.share, size: 20), 
              onPressed: () => _share(context, myUser, widget.setting, widget.bike.fork, widget.bike.shock),
            ),
          ),
          child: Material(
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    CupertinoTextField(
                      padding: EdgeInsets.all(10),
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      controller: _settingNameController,
                      placeholder: 'Setting Name',
                      keyboardType: TextInputType.text
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                child: Text($fork != null ? $fork['brand'] + ' ' + $fork['model'] : 'No fork saved'),
                                height: 40,
                              ),
                              Image.asset('assets/fox36-black.jpg', height: 50),
                              SizedBox(height: 20),
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
                              SizedBox(
                                child: Text($shock != null ? $shock['brand'] + ' ' + $shock['model'] : 'No shock saved'),
                                height: 40,
                              ),
                              Image.asset('assets/fox-dpx2.png', height: 50),
                              SizedBox(height: 20),
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
                                controller: _hsrShockController,
                                keyboardType: TextInputType.text
                              ),
                              TextField(
                                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'LSR',
                                  labelText: 'LSR',
                                ),
                                controller: _lsrShockController,
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
                        _updateSetting(widget.bike.id, context)
                    ),
                    // Expanded(child: Container())
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _share(context, User user, String setting, fork, shock) {
    final String text = "Suspension Pro setting '$setting' from ${user.username}";
    print(text);
    Share.share(text, subject: setting);
  }
}