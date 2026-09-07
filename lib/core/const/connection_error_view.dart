import 'package:flutter/material.dart';

import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

class PageLoadingView extends StatelessWidget {
  final String? message;

  const PageLoadingView({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message ?? localizations.loading_data,
              textAlign: TextAlign.center,
              style: AppTextStyles.text15(
                context,
                isBold: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectionErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final bool isLoading;

  const ConnectionErrorView({
    super.key,
    required this.onRetry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // =========================
              // Connection Icon
              // =========================
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              // =========================
              // Title
              // =========================
              Text(
                localizations.no_Internet,
                textAlign: TextAlign.center,
                style: AppTextStyles.text19Bold(
                  context,
                ),
              ),

              const SizedBox(height: 8),

              // =========================
              // Description
              // =========================
              Text(
                localizations.no_internet_connection,
                textAlign: TextAlign.center,
                style: AppTextStyles.text13Grey(
                  context,
                ),
              ),

              const SizedBox(height: 24),

              // =========================
              // Retry Button
              // =========================
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : onRetry,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                        ),
                  label: Text(
                    isLoading
                        ? localizations.loading_data
                        : localizations.retry,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
