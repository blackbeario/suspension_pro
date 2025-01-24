import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  logError(String eventName, Object? error) {
    analytics.logEvent(name: eventName, parameters: {'error': error!});
  }

  logEvent(String eventName, Object? message) {
    analytics.logEvent(name: eventName, parameters: {'event': message!});
  }
}