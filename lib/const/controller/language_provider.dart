import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  LanguageProvider() {
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString('language') ?? 'ar';

    _locale = Locale(languageCode);

    notifyListeners();
  }

  Future<void> changeLanguage(bool arabic) async {
    final prefs = await SharedPreferences.getInstance();

    _locale = arabic ? const Locale('ar') : const Locale('en');

    await prefs.setString(
      'language',
      _locale.languageCode,
    );

    notifyListeners();
  }
}
