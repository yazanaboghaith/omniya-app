import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:omniya/core/const/controller/language_provider.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/view/auth/log_in.dart';
import 'package:provider/provider.dart';
import 'package:omniya/firebase_options.dart';
import 'package:omniya/core/services/token_refresh_worker.dart';
import 'package:omniya/core/services/auth_storage.dart';
import 'package:omniya/core/firebase/firebase_services.dart';
import 'package:omniya/core/firebase/notification_service.dart';
import 'package:omniya/view/home/splash/splash.dart';
import 'package:omniya/view/home/notification/controller/notifications_controller.dart';
import 'package:omniya/view/home/notification/notifications.dart';
import 'package:omniya/core/const/controller/theme_controller.dart';
import 'package:omniya/core/const/multi_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final LocalAuthentication auth = LocalAuthentication();
final AuthStorage storage = AuthStorage();

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // print("BACKGROUND NOTIFICATION: ${message.data}");
}

Future<bool> checkUserSecurity() async {
  final token = await storage.getToken();

  if (token == null || token.isEmpty) {
    // print("NO USER LOGGED IN");
    return false;
  }

  final type = await storage.getSecurityType();

  if (type == "pin") {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.enter_pin),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, controller.text == "1234");
            },
            child: Text(AppLocalizations.of(context)!.login),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  if (type == "bio") {
    try {
      final context = navigatorKey.currentContext;

      return await auth.authenticate(
        localizedReason: context != null
            ? AppLocalizations.of(context)!.identity_verification
            : "Identity verification",
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      return false;
    }
  }

  return true;
}

class NotificationFlow {
  static RemoteMessage? pendingMessage;
  static bool _isProcessing = false;

  static Future<void> setPending(RemoteMessage message) async {
    pendingMessage = message;
  }

  static Future<void> processPending() async {
    if (_isProcessing) return;
    if (pendingMessage == null) return;

    _isProcessing = true;

    final message = pendingMessage!;
    pendingMessage = null;

    await handleNotification(message);

    _isProcessing = false;
  }
}

Future<void> handleNotification(RemoteMessage message) async {
  final notificationId = message.data['notification_id']?.toString();

  if (notificationId != null && notificationId.isNotEmpty) {
    await NotificationsController().trackOpen(notificationId);
  }

  final token = await storage.getToken();

  if (token == null || token.isEmpty) {
    NotificationFlow.pendingMessage = message;

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => Login()),
    );
    return;
  }

  final allowed = await checkUserSecurity();
  if (!allowed) return;

  navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const Notifications()),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await ThemeController.init();
  await FirebaseServices.init();
  await LanguageProvider.init();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission();

  final worker = TokenRefreshWorker();
  worker.start();

  await NotificationService.init();

  FirebaseMessaging.onMessage.listen((message) {
    NotificationService.showNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    await NotificationFlow.setPending(message);
    await NotificationFlow.processPending();
  });

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    await NotificationFlow.setPending(initialMessage);
    await NotificationFlow.processPending();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: listproviders,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.themeMode,
        builder: (context, mode, _) {
          return Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                locale: languageProvider.locale,
                supportedLocales: const [
                  Locale('ar'),
                  Locale('en'),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: ThemeData(
                  brightness: Brightness.light,
                  fontFamily: 'Cairo',
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  fontFamily: 'Cairo',
                ),
                themeMode: mode,
                builder: (context, child) {
                  return Directionality(
                    textDirection: languageProvider.isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child!,
                  );
                },
                home: const Splash(),
              );
            },
          );
        },
      ),
    );
  }
}
