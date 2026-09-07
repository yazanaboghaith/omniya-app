import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

class RouterEmptyState extends StatelessWidget {
  final bool isRefreshing;
  final Future<void> Function() onRetry;

  const RouterEmptyState({
    super.key,
    required this.isRefreshing,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRetry,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final circleSize = width >= 600
              ? 125.0
              : width < 360
                  ? 95.0
                  : 110.0;

          final iconSize = circleSize * 0.5;

          final titleSize = width >= 600
              ? 22.0
              : width < 360
                  ? 17.0
                  : 19.0;

          final horizontalPadding = width >= 600
              ? 80.0
              : width < 360
                  ? 20.0
                  : 30.0;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: height * 0.2,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: Column(
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: 0.10,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.router_outlined,
                        size: iconSize,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.router_no_brands,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.text(context),
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.router_no_brands_message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grey(context),
                        fontSize: width < 360 ? 12 : 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _RetryButton(
                      isRefreshing: isRefreshing,
                      onRetry: onRetry,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final bool isRefreshing;
  final Future<void> Function() onRetry;

  const _RetryButton({
    required this.isRefreshing,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;

    return ElevatedButton.icon(
      onPressed: isRefreshing ? null : onRetry,
      icon: isRefreshing
          ? SizedBox(
              width: width < 360 ? 18 : 20,
              height: width < 360 ? 18 : 20,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(
              Icons.refresh_rounded,
            ),
      label: Text(
        isRefreshing ? l10n.loading_data : l10n.retry,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: width >= 600
              ? 30
              : width < 360
                  ? 20
                  : 25,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
