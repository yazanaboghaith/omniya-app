import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseServices {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Future<void> init() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
      return true;
    };

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }
}
