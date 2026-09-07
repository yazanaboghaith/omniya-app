import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

class RouterSelectionHeader extends StatelessWidget {
  const RouterSelectionHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;

    final titleSize = width >= 600
        ? 30.0
        : width < 360
            ? 24.0
            : 27.0;

    final subtitleSize = width >= 600 ? 15.0 : 13.5;

    return Column(
      children: [
        Text(
          l10n.router_choose_device,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text(context),
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.router_choose_brand,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.grey(context),
            fontSize: subtitleSize,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
