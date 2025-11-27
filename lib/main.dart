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
import 'package:ridemetrx/core/services/sync_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool showHome = prefs.getBool('showHome') ?? false;
  await dotenv.load(fileName: ".env.dev"); // TODO: change to prod
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await registerAdapters();

  // Initialize RevenueCat
  await _initializeRevenueCat();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(ProviderScope(child: MyApp(showHome: showHome)));
}

/// Initialize RevenueCat SDK with platform-specific API keys
Future<void> _initializeRevenueCat() async {
  // Enable debug logs in development
  await Purchases.setLogLevel(LogLevel.debug);

  // Get API key from environment
  // final apiKey = dotenv.env['REVENUECAT_SANDBOX_API_KEY'];
  final apiKey = Platform.isIOS
      ? dotenv.env['REVENUECAT_IOS_API_KEY']
      : dotenv.env['REVENUECAT_ANDROID_API_KEY']; // TODO: Set your Android key

  if (apiKey == null || apiKey.isEmpty) {
    print('RevenueCat: Warning - API key not found in .env file');
    return;
  }

  // Configure RevenueCat
  final configuration = PurchasesConfiguration(apiKey);
  await Purchases.configure(configuration);

  print('RevenueCat: Initialized successfully');
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

    // Listen to connectivity changes and trigger sync when going online
    ref.listen<bool>(connectivityNotifierProvider, (previous, current) {
      // If previous was offline (false) and current is online (true)
      if (previous == false && current == true) {
        print('App: Connectivity restored, triggering sync...');
        ref.read(syncServiceProvider.notifier).syncDirtyData();
      }
    });

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: SusProTheme().themedata,
    );
  }
}
