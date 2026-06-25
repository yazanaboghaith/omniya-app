import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.fromLTRB(w * 0.05, w * 0.01, w * 0.05, h * 0.02),
      height: h * 0.075,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: AppColors.grey(context).withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: isDark
                ? AppColors.text(context).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(
                    context, Icons.home, AppLocalizations.of(context)!.home, 0),
                _item(context, Icons.account_balance,
                    AppLocalizations.of(context)!.payments, 1),
                _item(context, Icons.assignment,
                    AppLocalizations.of(context)!.requests, 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String text, int index) {
    final selected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 26 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: selected
              ? (isDark
                  ? AppColors.text(context).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.1))
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  selected ? AppColors.text(context) : AppColors.text(context),
            ),
            const SizedBox(height: 3),
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? AppColors.text(context)
                    : AppColors.text(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
