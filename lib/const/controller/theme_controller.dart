import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.system,
  );

  static const String _key = "theme_mode";

  /// تحميل الثيم عند تشغيل التطبيق
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_key);

    if (savedTheme == null) {
      themeMode.value = ThemeMode.system;
      return;
    }

    switch (savedTheme) {
      case "dark":
        themeMode.value = ThemeMode.dark;
        break;
      case "light":
        themeMode.value = ThemeMode.light;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
  }

  /// معرفة الوضع الحالي
  static bool get isDark {
    if (themeMode.value == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  }

  /// تغيير الثيم + حفظه
  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (isDark) {
      themeMode.value = ThemeMode.light;
      await prefs.setString(_key, "light");
    } else {
      themeMode.value = ThemeMode.dark;
      await prefs.setString(_key, "dark");
    }
  }

  /// إعادة النظام (اختياري)
  static Future<void> setSystemTheme() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode.value = ThemeMode.system;
    await prefs.setString(_key, "system");
  }
}
