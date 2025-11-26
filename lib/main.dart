import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:ridemetrx/core/hive_helper/register_adapters.dart';
import 'package:ridemetrx/core/routing/app_router.dart';
import 'package:ridemetrx/core/themes/styles.dart';
import 'package:ridemetrx/features/auth/presentation/auth_state_listener.dart';
import 'package:ridemetrx/features/connectivity/domain/connectivity_notifier.dart';
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
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(ProviderScope(child: MyApp(showHome: showHome)));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key, required this.showHome}) : super(key: key);
  final bool showHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Initialize connectivity check on app start
    ref.read(connectivityNotifierProvider.notifier).checkConnectivity();

    // Listen to Firebase auth state changes
    ref.watch(authStateListenerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: SusProTheme().themedata,
    );
  }
}
