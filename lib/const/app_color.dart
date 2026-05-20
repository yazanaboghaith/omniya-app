import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF92509F);
  static const secondary = Color(0xFF243D6B);
  static const speed = Color(0xFF395FA5);
  static const secondaryText = Color(0xff6499FF);

  static Color text(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black;
  }

  static Color grey(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white60 : Colors.black54;
  }
}

class AppTextStyles {
  static TextStyle text24(
    BuildContext context, {
    bool isBold = true,
    Color? color,
  }) {
    return TextStyle(
      color: color ?? AppColors.text(context),
      fontSize: 24,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
  }

  static TextStyle text13(
    BuildContext context, {
    bool isBold = false,
    Color? color,
  }) {
    return TextStyle(
      color: color ?? AppColors.text(context),
      fontSize: 13,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
  }

  static TextStyle text15(
    BuildContext context, {
    bool isBold = false,
    Color? color,
  }) {
    return TextStyle(
      color: color ?? AppColors.text(context),
      fontSize: 15,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
  }

  static TextStyle text17Bold(BuildContext context, {Color? color}) {
    return TextStyle(
      color: color ?? AppColors.text(context),
      fontSize: 17,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle text19Bold(BuildContext context, {Color? color}) {
    return TextStyle(
      color: color ?? AppColors.text(context),
      fontSize: 19,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle text50(BuildContext context, {Color? color}) {
    return TextStyle(
      color: color ?? AppColors.text(context),
      fontSize: 50,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle text20Grey(BuildContext context) {
    return TextStyle(color: AppColors.grey(context), fontSize: 20);
  }

  static TextStyle text15Grey(BuildContext context) {
    return TextStyle(color: AppColors.grey(context), fontSize: 15);
  }

  static TextStyle text13Grey(BuildContext context) {
    return TextStyle(color: AppColors.grey(context), fontSize: 13);
  }

  static TextStyle text10Grey(BuildContext context) {
    return TextStyle(color: AppColors.grey(context), fontSize: 10);
  }

  static TextStyle text15BlackBold() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle text13BlackBold() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 13,
      fontWeight: FontWeight.bold,
    );
  }

  // SECONDARY
  static const TextStyle text15SecondaryBold = TextStyle(
    color: AppColors.secondaryText,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );
}
