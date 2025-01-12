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
import 'package:suspension_pro/themes/styles.dart';
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
        app: MaterialApp(
          navigatorKey: MyApp.navigatorKey,
          localizationsDelegates: [
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: SusProTheme().themedata,
          home: showHome ? AuthenticationWrapper() : Onboarding(),
        ),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final DatabaseService _db = DatabaseService();
    final UserSingleton _user = UserSingleton();
    return ConnectivityWidgetWrapper(
        offlineWidget: _user.uid.isEmpty
            ? ListenableBuilder(
                listenable: _user,
                builder: (context, widget) {
                  return _user.uid.isEmpty ? LoginPage(online: false) : AppHomePage();
                })
            : AppHomePage(),
        child: StreamBuilder<User?>(
            stream: authService.user,
            builder: (_, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                final User? user = snapshot.data;
                if (user != null) {
                  // Get the Firebase user doc
                  return StreamBuilder<AppUser?>(
                      stream: _db.streamUser(user.uid),
                      builder: (context, snapshot) {
                        final AppUser? fbUser = snapshot.data;
                        if (fbUser == null) {
                          return Center(child: CupertinoActivityIndicator(animating: true));
                        }
                        // set UserSingleton properties
                        // for new users this will just be uid & email
                        // for existing users this will include username, 
                        // firstName and lastName (if they've completed the profile form)
                        // && pro_account if they've purchased 
                        UserSingleton().setNewUser(user.uid, fbUser);
                        // Set all Hive user values if they exist
                        AuthService().addUpdateHiveUser(user.uid, fbUser);
                        return AppHomePage();
                      });
                } else
                  return LoginPage(online: true);
              } else {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }
            }));
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
            icon: Icon(CupertinoIcons.profile_circled, size: 24),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined, size: 24),
            label: 'Ai',
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
