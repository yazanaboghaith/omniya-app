import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/setting/router_model.dart';

class RouterOverviewWidget extends StatelessWidget {
  final RouterModel router;

  const RouterOverviewWidget({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final small = width < 380;
    final medium = width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        small
            ? 14
            : medium
                ? 17
                : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(
          small ? 20 : 26,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 18),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 430) {
            return _smallLayout(context);
          }

          return _largeLayout(context);
        },
      ),
    );
  }

  Widget _smallLayout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: Colors.white.withValues(alpha: .18),
            ),
          ),
          child: const Icon(
            Icons.router_rounded,
            color: Colors.white,
            size: 33,
          ),
        ),
        const SizedBox(height: 14),
        _routerText(context),
        const SizedBox(height: 12),
        _networkBadge(context, l10n),
      ],
    );
  }

  Widget _largeLayout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.white.withValues(alpha: .18),
            ),
          ),
          child: const Icon(
            Icons.router_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _routerText(context),
        ),
        const SizedBox(width: 14),
        _networkBadge(context, l10n),
      ],
    );
  }

  Widget _routerText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          router.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          router.modelNumber,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .78),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _networkBadge(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_rounded,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            l10n.router_local_network,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
