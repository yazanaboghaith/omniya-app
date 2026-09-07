import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static String? _savedLanguageCode;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _savedLanguageCode = prefs.getString('language');

    debugPrint('========================================');
    debugPrint('[LANGUAGE] INITIALIZATION');
    debugPrint('[LANGUAGE] SAVED LANGUAGE => $_savedLanguageCode');
    debugPrint(
      '[LANGUAGE] DEVICE LANGUAGE => '
      '${PlatformDispatcher.instance.locale.languageCode}',
    );
    debugPrint('========================================');
  }

  Locale _locale = _getInitialLocale();

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  static Locale _getInitialLocale() {
    // إذا كان المستخدم اختار لغة سابقاً
    if (_savedLanguageCode != null && _savedLanguageCode!.trim().isNotEmpty) {
      debugPrint(
        '[LANGUAGE] Using saved language => $_savedLanguageCode',
      );

      return Locale(_savedLanguageCode!);
    }

    // إذا لم توجد لغة محفوظة، نأخذ لغة الجهاز
    final deviceLanguage =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();

    final languageCode = deviceLanguage == 'ar' ? 'ar' : 'en';

    debugPrint(
      '[LANGUAGE] No saved language.',
    );

    debugPrint(
      '[LANGUAGE] Device language => $deviceLanguage',
    );

    debugPrint(
      '[LANGUAGE] Using language => $languageCode',
    );

    return Locale(languageCode);
  }

  Future<void> changeLanguage(bool arabic) async {
    final prefs = await SharedPreferences.getInstance();

    _locale = arabic ? const Locale('ar') : const Locale('en');

    await prefs.setString(
      'language',
      _locale.languageCode,
    );

    _savedLanguageCode = _locale.languageCode;

    debugPrint('========================================');
    debugPrint('[LANGUAGE] LANGUAGE CHANGED');
    debugPrint(
      '[LANGUAGE] NEW LANGUAGE => ${_locale.languageCode}',
    );
    debugPrint('========================================');

    notifyListeners();
  }
}
