import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/l10n/app_localizations.dart';
import 'package:omniya/view/home/home_page/controller/home_page_controller.dart';

class RenewSubscriptionDialogs {
  RenewSubscriptionDialogs._();

  static void show(BuildContext context, HomePageController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: _dialogGlassDecoration(context),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.subscription_extension_options,
                        style: AppTextStyles.text19Bold(context),
                      ),
                      const SizedBox(height: 24),
                      _buildOptionTile(
                        context: context,
                        title: l10n.extension_for_1_day,
                        price: l10n.free,
                        onTap: () => _showConfirmationDialog(
                          context,
                          controller,
                          "1",
                          l10n.free_of_charge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildOptionTile(
                        context: context,
                        title: l10n.extension_for_2_days,
                        price: "10 ${l10n.currency}",
                        onTap: () => _showConfirmationDialog(
                          context,
                          controller,
                          "2",
                          "10 ${l10n.currency}",
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildOptionTile(
                        context: context,
                        title: l10n.extension_for_3_days,
                        price: "150 ${l10n.currency}",
                        onTap: () => _showConfirmationDialog(
                          context,
                          controller,
                          "3",
                          "150 ${l10n.currency}",
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          side: BorderSide(
                            color:
                                AppColors.text(context).withValues(alpha: 0.3),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: TextStyle(
                            color:
                                AppColors.text(context).withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void _showConfirmationDialog(
    BuildContext context,
    HomePageController controller,
    String duration,
    String cost,
  ) {
    final l10n = AppLocalizations.of(context)!;

    Navigator.pop(context);

    bool isLoading = false;
    bool showResult = false;
    bool isSuccess = false;
    String message = "";

    final daysText = int.tryParse(
          duration.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        1;

    String durationText;
    switch (daysText) {
      case 1:
        durationText = l10n.day;
        break;
      case 2:
        durationText = l10n.two_days;
        break;
      default:
        durationText = "$daysText ${l10n.days}";
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: _dialogGlassDecoration(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(l10n.processing_Payment),
                        ] else if (showResult) ...[
                          Icon(
                            isSuccess
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            size: 60,
                            color: isSuccess ? Colors.green : Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.text15(context),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.confirm_extension,
                            style: AppTextStyles.text19Bold(context),
                          ),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              text:
                                  "${l10n.confirm_extension_message} $durationText ",
                              children: [
                                TextSpan(
                                  text: cost,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.cancel,
                                      style: AppTextStyles.text15(context)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.green.withValues(alpha: 0.6),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    final days = int.tryParse(
                                          duration.replaceAll(
                                              RegExp(r'[^0-9]'), ''),
                                        ) ??
                                        1;

                                    final result =
                                        await controller.extendSubscription(
                                      context: context,
                                      days: days,
                                    );

                                    setState(() {
                                      isLoading = false;
                                      showResult = true;
                                      isSuccess = result == "success";
                                      message = result == "success"
                                          ? l10n.extension_success
                                          : l10n.extension_failed;
                                    });

                                    await Future.delayed(
                                      const Duration(seconds: 2),
                                    );

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(l10n.confirm,
                                      style: AppTextStyles.text15(context)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required String price,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.text(context).withValues(alpha: 0.1),
          ),
          color: AppColors.text(context).withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(price),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _dialogGlassDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        width: 1,
        color: AppColors.text(context).withValues(alpha: 0.1),
      ),
      color: isDark
          ? AppColors.text(context).withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.3),
    );
  }
}
