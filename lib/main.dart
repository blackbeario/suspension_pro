import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:suspension_pro/models/user.dart';
import 'package:suspension_pro/features/forms/openai_form.dart';
import './services/auth_service.dart';
import 'features/auth/login.dart';
import 'features/profile/profile.dart';
import 'features/settings/settings.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

enum DeviceType { Phone, Tablet }

DeviceType getDeviceType() {
  BuildContext context = MyApp.navigatorKey.currentContext!;
  final screenWidth = MediaQuery.sizeOf(context).width;
  return screenWidth < 550 ? DeviceType.Phone : DeviceType.Tablet;
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // print(getDeviceType());
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
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
            barBackgroundColor: Color(0xFFE5E5EA),
          ),
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

class AppHomePage extends StatefulWidget {
  AppHomePage(this.user);
  final AppUser user;

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings, size: 24),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled, size: 24),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined, size: 24),
            label: 'AI',
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      tabBuilder: (BuildContext context, int index) {
        assert(index >= 0 && index <= 2);
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (BuildContext context) => Settings(user: widget.user),
            );
          case 1:
            return CupertinoTabView(
              builder: (BuildContext context) => Profile(user: widget.user),
            );
          case 2:
            return CupertinoTabView(
              builder: (BuildContext context) => OpenAiRequest(userID: widget.user.id),
            );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
