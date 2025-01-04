import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:suspension_pro/features/in_app_purchases/buy_credits.dart';
import 'package:suspension_pro/features/in_app_purchases/in_app_bloc.dart';
import 'package:suspension_pro/features/connectivity/connectivity_bloc.dart';
import 'package:suspension_pro/features/onboarding/onboarding.dart';
import 'package:suspension_pro/features/forms/openai_form.dart';
import 'package:suspension_pro/hive_helper/register_adapters.dart';
import 'package:suspension_pro/models/user.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'package:suspension_pro/services/db_service.dart';
import './services/auth_service.dart';
import 'features/auth/login.dart';
import 'features/profile/profile.dart';
import 'features/bikes/bikes_list_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool showHome = prefs.getBool('showHome') ?? false;
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await registerAdapters();
  await ConnectivityBloc().checkConnectivity();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp(showHome: showHome));
}

enum DeviceType { Phone, Tablet }

DeviceType getDeviceType() {
  BuildContext context = MyApp.navigatorKey.currentContext!;
  final screenWidth = MediaQuery.sizeOf(context).width;
  return screenWidth < 550 ? DeviceType.Phone : DeviceType.Tablet;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.showHome}) : super(key: key);
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final bool showHome;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: ConnectivityAppWrapper(
        app: CupertinoApp(
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
          home: showHome ? AuthenticationWrapper() : Onboarding(),
        ),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ConnectivityBloc _connectionBloc = ConnectivityBloc();
    final DatabaseService db = DatabaseService();
    return ListenableBuilder(
      listenable: _connectionBloc,
      builder: (context, widget) {

        // App is ONLINE
        if (_connectionBloc.isConnected) {
          final authService = Provider.of<AuthService>(context);
          return StreamBuilder<User?>(
              stream: authService.user,
              builder: (_, AsyncSnapshot<User?> snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final User? user = snapshot.data;
                  if (user != null) {
                    // set UserSingleton properties
                    UserSingleton().uid = user.uid;
                    UserSingleton().email = user.email ?? '';

                    // Get the Firebase user doc for username and pro_account status
                    return StreamBuilder<AppUser?>(
                        stream: db.streamUser(),
                        builder: (context, snapshot) {
                          final AppUser? fbUser = snapshot.data;
                          if (fbUser == null) {
                            return Center(child: CupertinoActivityIndicator(animating: true));
                          }
                          UserSingleton().username = fbUser.username ?? 'Guest';
                          UserSingleton().proAccount = fbUser.proAccount ?? false;
                          return AppHomePage();
                        });
                  } else
                    return LoginPage();
                } else {
                  return Scaffold(body: Center(child: CircularProgressIndicator()));
                }
              });
        }
        // App is OFFLINE 
        return UserSingleton().username == '' ? LoginPage() : AppHomePage();
      },
    );
  }
}

class AppHomePage extends StatefulWidget {
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
            icon: Icon(Icons.format_list_bulleted_rounded, size: 24),
            label: 'Bikes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings, size: 24),
            label: 'App',
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
              builder: (BuildContext context) => BikesListScreen(),
            );
          case 1:
            return CupertinoTabView(
              builder: (BuildContext context) => Profile(),
            );
          case 2:
            return CupertinoTabView(
              builder: (BuildContext context) {
                final InAppBloc _bloc = InAppBloc();
                return ListenableBuilder(
                    listenable: _bloc,
                    builder: (context, widget) {
                      if (_bloc.credits == 0) {
                        return BuyCredits();
                      }
                      return OpenAiRequest();
                    });
              },
            );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
