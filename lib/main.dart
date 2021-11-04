import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:suspension_pro/models/user.dart';
import './services/auth_service.dart';
import './login.dart';
import './profile.dart';
import './settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
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
            primaryContrastingColor: Color(0xFFFFFFFF),
            barBackgroundColor: Color(0xFFE5E5EA)),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Instance to know the authentication state.
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<AppUser?>(
        stream: authService.user,
        builder: (_, AsyncSnapshot<AppUser?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final AppUser? user = snapshot.data;
            return user == null ? LoginPage() : AppHomePage(user);
          } else {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        });
  }
}

class AppHomePage extends StatelessWidget {
  AppHomePage(this.user);
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            label: 'Profile',
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      tabBuilder: (BuildContext context, int index) {
        assert(index >= 0 && index <= 2);
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (BuildContext context) => Settings(),
            );
          case 1:
            return CupertinoTabView(
              builder: (BuildContext context) => Profile(uid: user.id),
            );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
