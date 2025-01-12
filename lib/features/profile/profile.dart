import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:suspension_pro/features/roadmap/app_roadmap.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'package:suspension_pro/utilities/helpers.dart';
import 'package:suspension_pro/features/profile/profile_pic.dart';
import 'package:suspension_pro/features/profile/profile_form.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import 'package:flutter/cupertino.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final db = DatabaseService();
  final UserSingleton _user = UserSingleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileForm())),
            child: Text('Edit'),
          ),
        ],
        title: Text(_user.userName),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Column(
            children: [
              ProfilePic(size: 100),
              Text((_user.firstName) + ' ' + (_user.lastName), style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text(_user.email)
            ],
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text('App Settings'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => {}, // TODO create settings screen
            ),
          ),
          ListTile(
            title: Text('App Roadmap'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppRoadmap())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text('Privacy Policy'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => loadURL('https://vibesoftware.io/privacy/suspension_pro'),
            ),
          ),
          ListTile(
            title: Text('Terms & Conditions'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => loadURL('https://vibesoftware.io/terms/suspension_pro'),
          ),
          SizedBox(height: 40),
          ListTile(
            leading: Icon(Icons.power_settings_new, color: Colors.red),
            tileColor: Colors.grey.shade100,
            title: Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => _signOut(context),
          )
        ],
      ),
    );
  }

  _signOut(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Sign Out'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.pop(context, 'Discard');
                  context.read<AuthService>().signOut();
                }),
            CupertinoDialogAction(
              child: Text('Cancel'),
              isDefaultAction: true,
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
            ),
          ],
        );
      },
    );
  }
}
