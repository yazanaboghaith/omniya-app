import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:omniya/view/auth/services/token_refresh_worker.dart';
import 'package:omniya/view/home/splash/splash.dart';
import 'package:provider/provider.dart';

import 'package:omniya/const/controller/theme_controller.dart';
import 'package:omniya/const/multi_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.init();
  final worker = TokenRefreshWorker();
  worker.start();
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
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],

            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            theme: ThemeData(brightness: Brightness.light, fontFamily: 'Cairo'),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Cairo',
            ),

            themeMode: mode,

            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },

            home: const Splash(),
          );
        },
      ),
    );
  }
}
