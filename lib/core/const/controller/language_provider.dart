import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static String? _savedLanguageCode;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _savedLanguageCode = prefs.getString('language');
  }

  Locale _locale = _getInitialLocale();

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  static Locale _getInitialLocale() {
    if (_savedLanguageCode != null) {
      return Locale(_savedLanguageCode!);
    }

    final lang = PlatformDispatcher.instance.locale.languageCode.toLowerCase();

    return lang == 'ar' ? const Locale('ar') : const Locale('en');
  }

  Future<void> changeLanguage(bool arabic) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = arabic ? const Locale('ar') : const Locale('en');
    await prefs.setString('language', _locale.languageCode);
    notifyListeners();
  }
}
