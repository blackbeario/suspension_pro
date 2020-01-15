import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for iOS
// import 'package:cloud_firestore/cloud_firestore.dart';
import './services/db_service.dart';
import './services/auth_service.dart';
import './login.dart';
import './profile.dart';
import './settings.dart';

void main() => runApp(MyApp());

final db = DatabaseService();
final AuthService auth = AuthService();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider<FirebaseUser>(builder: (_) => AuthService().user),
        ],
        child: CupertinoApp(
          localizationsDelegates: [
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(
            primaryColor: Color(0xFF007AFF), // iOS 10's default blue
            primaryContrastingColor: Color(0xFFFFFFFF), // iOS 10's default blue 
            barBackgroundColor: Color(0xFFE5E5EA)
          ),
          home: AppHomePage(),
        ),
      );
  }
}

class AppHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    bool loggedIn = user != null;
      if (loggedIn) {
        return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                title: Text('Settings'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.profile_circled),
                title: Text('Profile'),
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
          tabBuilder: (BuildContext context, int index) {
            assert(index >= 0 && index <=2);
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (BuildContext context) => Settings(),
                );
                break;
              case 1:
                return CupertinoTabView(
                  builder: (BuildContext context) => Profile(uid: user.uid),
                );
                break;
              }
              return null;
          },
        );
      }
      else return LoginPage();
  }
}