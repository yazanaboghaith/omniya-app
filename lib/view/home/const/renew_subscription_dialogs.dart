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
                        l10n.subscriptionextensionoptions,
                        style: AppTextStyles.text19Bold(context),
                      ),
                      const SizedBox(height: 24),
                      _buildOptionTile(
                        context: context,
                        title: l10n.extensionfor1day,
                        price: l10n.free,
                        onTap: () => _showConfirmationDialog(
                          context,
                          controller,
                          "1",
                          l10n.freeofcharge,
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
                              horizontal: 30, vertical: 10),
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

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext context) {
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
                          text: "${l10n.confirm_extension_message} $duration ",
                          children: [
                            TextSpan(
                              text: cost,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                // color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style:
                            AppTextStyles.text15(context).copyWith(height: 1.5),
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
                              onPressed: () async {
                                debugPrint(
                                    "========== USER CLICKED CONFIRM ==========");
                                debugPrint("Duration raw string => $duration");

                                final days = int.tryParse(
                                      duration.replaceAll(
                                          RegExp(r'[^0-9]'), ''),
                                    ) ??
                                    1;

                                debugPrint("Parsed days => $days");

                                Navigator.pop(context);

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                debugPrint("Calling extendSubscription...");

                                await controller.extendSubscription(days: days);

                                debugPrint("Returned from extendSubscription");

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  debugPrint("Loading dialog closed");
                                }

                                debugPrint(
                                    "========== FLOW COMPLETE ==========");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green.withValues(alpha: 0.6),
                              ),
                              child: Text(
                                l10n.confirm,
                                style: AppTextStyles.text15(context),
                              ),
                            ),
                          ),
                        ],
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
            Text(title, style: AppTextStyles.text15(context)),
            Text(price, style: AppTextStyles.text13(context)),
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
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      color: isDark
          ? AppColors.text(context).withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.3),
    );
  }
}
