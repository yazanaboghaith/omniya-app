import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/const/color.dart';
import 'package:omniya/const/controller/language_provider.dart';
import 'package:omniya/l10n/app_localizations.dart';
import 'package:omniya/model/user_model.dart';
import 'package:omniya/view/auth/services/auth_storage.dart';
import 'package:omniya/view/home/splash/splash.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ProfileBottomSheet extends StatefulWidget {
  final UserModel? user;

  const ProfileBottomSheet({super.key, required this.user});

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languageProvider = context.watch<LanguageProvider>();
    final size = MediaQuery.of(context).size;
    double height = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection:
          languageProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: isDark
                            ? AppColors.text(context).withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.8),
                        border: Border.all(
                          color: AppColors.text(context).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.text(context)
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Text(
                            AppLocalizations.of(context)!.account_Info,
                            style: AppTextStyles.text24(context),
                          ),
                          SizedBox(height: height * 0.02),
                          _buildItem(
                            context,
                            title: AppLocalizations.of(context)!.user_name,
                            value: widget.user?.arabicName ??
                                widget.user?.username ??
                                "--",
                          ),
                          Divider(
                            color:
                                AppColors.text(context).withValues(alpha: 0.2),
                          ),
                          _buildItem(
                            context,
                            title: AppLocalizations.of(context)!.phone,
                            value: widget.user?.phone ??
                                widget.user?.mobile ??
                                "--",
                          ),
                          Divider(
                            color:
                                AppColors.text(context).withValues(alpha: 0.2),
                          ),
                          _buildItem(
                            context,
                            title: AppLocalizations.of(context)!.service_name,
                            value: widget.user?.baseService.name ?? "--",
                          ),
                          Divider(
                            color:
                                AppColors.text(context).withValues(alpha: 0.2),
                          ),
                          _buildItem(
                            context,
                            title: AppLocalizations.of(context)!
                                .monthly_subscription,
                            value:
                                "${widget.user?.baseService.regPrice ?? 0} ل.س.ج",
                          ),
                          Divider(
                            color:
                                AppColors.text(context).withValues(alpha: 0.2),
                          ),
                          _buildItem(
                            context,
                            title: AppLocalizations.of(context)!.expiry_date,
                            value: widget.user?.expiryDate ?? "--",
                          ),
                          Divider(
                            color:
                                AppColors.text(context).withValues(alpha: 0.2),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.language,
                                  style: AppTextStyles.text17Bold(context),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      languageProvider.isArabic
                                          ? AppLocalizations.of(context)!.arabic
                                          : "English",
                                      style: AppTextStyles.text15(context),
                                    ),
                                    const SizedBox(width: 10),
                                    Switch(
                                      value: languageProvider.isArabic,
                                      onChanged: (value) async {
                                        await languageProvider
                                            .changeLanguage(value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor:
                                          Colors.green.withValues(alpha: 0.6),
                                      inactiveThumbColor:
                                          AppColors.text(context),
                                      inactiveTrackColor:
                                          Colors.grey.withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color:
                                AppColors.text(context).withValues(alpha: 0.2),
                          ),
                          SizedBox(height: height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.user_Status,
                                style: AppTextStyles.text17Bold(context),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: widget.user?.status == "Active"
                                      ? Colors.green.withValues(alpha: 0.6)
                                      : Colors.red.withValues(alpha: 0.8),
                                ),
                                child: Text(
                                  widget.user?.arabicStatus ?? "--",
                                  style: AppTextStyles.text15(context),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.025),
                          SizedBox(
                            width: size.width > 400 ? 200 : double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _handleLogout(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppColors.text(context)
                                        .withValues(alpha: 0.2)
                                    : AppColors.text(context)
                                        .withValues(alpha: 0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.logout,
                                      style: AppTextStyles.text15BlackBold(),
                                    ),
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Text("v1.0.0", style: AppTextStyles.text13(context)),
                          SizedBox(height: height * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.text(context).withValues(alpha: 0.1),
                    width: 1,
                  ),
                  color: Colors.white30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.logout,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.text17Bold(context),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      AppLocalizations.of(context)!.confirm_logout,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.text15(context),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryText,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              AppLocalizations.of(context)!.confirm,
                              style: AppTextStyles.text15white(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white30,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
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
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final storage = AuthStorage();
      await storage.logout();

      if (!mounted) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ksecondarycolor,
          content: Center(
            child: Text(
              AppLocalizations.of(context)!.logout_success,
              style: AppTextStyles.text15(context),
            ),
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const Splash(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ksecondarycolor,
          content: Center(
            child: Text(
              AppLocalizations.of(context)!.logout_failed,
              style: AppTextStyles.text15(context),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(title,
                style: AppTextStyles.text15(context)
                    .copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.left,
                style: AppTextStyles.text15(context)),
          ),
        ],
      ),
    );
  }
}
