import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/const/color.dart';
import 'package:omniya/core/const/controller/language_provider.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/user_model.dart';
import 'package:omniya/view/auth/controll/log_in_controller.dart';
import 'package:omniya/view/home/home.dart';
import 'package:omniya/view/home/splash/splash.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ProfileBottomSheet extends StatefulWidget {
  final UserModel? user;

  const ProfileBottomSheet({
    super.key,
    required this.user,
  });

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  bool _isLoading = false;
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _appVersion = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languageProvider = context.watch<LanguageProvider>();
    final size = MediaQuery.sizeOf(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 5,
                  ),
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
                            color:
                                AppColors.text(context).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          AppLocalizations.of(context)!.account_Info,
                          style: AppTextStyles.text24(context),
                        ),
                        SizedBox(height: size.height * 0.02),
                        _buildItem(
                          context,
                          title: AppLocalizations.of(context)!.user_name,
                          value: widget.user?.username ?? "--",
                        ),
                        _buildDivider(context),
                        _buildItem(
                          context,
                          title: AppLocalizations.of(context)!.phone,
                          value:
                              widget.user?.phone ?? widget.user?.mobile ?? "--",
                        ),
                        _buildDivider(context),
                        _buildItem(
                          context,
                          title: AppLocalizations.of(context)!.service_name,
                          value: widget.user?.baseService.name ?? "--",
                        ),
                        _buildDivider(context),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  AppLocalizations.of(context)!.total_fees,
                                  softWrap: true,
                                  style: AppTextStyles.text15(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    "${(widget.user?.baseService.regPrice ?? 0) + (widget.user?.addonServices.where((service) => service.active).fold<int>(
                                          0,
                                          (sum, service) =>
                                              sum + service.regPrice,
                                        ) ?? 0)} ${AppLocalizations.of(context)!.syp}",
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style:
                                        AppTextStyles.text15(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () => _showFeesDialog(context),
                                    child: Text(
                                      AppLocalizations.of(context)!.details,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.text13(context)
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildDivider(context),
                        _buildItem(
                          context,
                          title: AppLocalizations.of(context)!.expiry_date,
                          value: widget.user?.expiryDate ?? "--",
                        ),
                        _buildDivider(context),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
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

                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType.fade,
                                            child: Home(),
                                          ),
                                        );
                                      }
                                    },
                                    // ignore: deprecated_member_use
                                    activeColor: Colors.white,
                                    activeTrackColor:
                                        Colors.green.withValues(alpha: 0.6),
                                    inactiveThumbColor: AppColors.text(context),
                                    inactiveTrackColor: Colors.grey.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildDivider(context),
                        SizedBox(height: size.height * 0.01),
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
                        SizedBox(height: size.height * 0.025),
                        SizedBox(
                          width: size.width > 400 ? 200 : double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _handleLogout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.text(context)
                                      .withValues(alpha: 0.2)
                                  : AppColors.text(context)
                                      .withValues(alpha: 0),
                              padding: const EdgeInsets.symmetric(
                                vertical: 17,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.logout,
                                    style: AppTextStyles.text15BlackBold(),
                                  ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          _appVersion.isEmpty ? "..." : "v$_appVersion",
                          style: AppTextStyles.text13(context),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
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

  // ============================================================
  Future<void> _showFeesDialog(BuildContext context) async {
    final user = widget.user;

    if (user == null) return;

    final baseServicePrice = user.baseService.regPrice;

    final activeAddons =
        user.addonServices.where((service) => service.active).toList();

    final total = baseServicePrice +
        activeAddons.fold<int>(
          0,
          (sum, service) => sum + service.regPrice,
        );

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        final screenSize = MediaQuery.sizeOf(dialogContext);

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenSize.width < 400 ? 16 : 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: screenSize.height * 0.78,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 8,
                  sigmaY: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color:
                          AppColors.text(dialogContext).withValues(alpha: 0.1),
                      width: 1,
                    ),
                    color: isDark
                        ? AppColors.text(dialogContext).withValues(alpha: 0.15)
                        : Colors.white30,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          AppLocalizations.of(dialogContext)!
                              .monthly_subscription,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.text17Bold(
                            dialogContext,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFeeRow(
                                context: dialogContext,
                                serviceName: user.baseService.name.isEmpty
                                    ? "--"
                                    : user.baseService.name,
                                price: baseServicePrice,
                              ),
                              ...activeAddons.map(
                                (service) => _buildFeeRow(
                                  context: dialogContext,
                                  serviceName: service.name.isEmpty
                                      ? "--"
                                      : service.name,
                                  price: service.regPrice,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Divider(
                                color: AppColors.text(dialogContext)
                                    .withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!.total,
                                      style: AppTextStyles.text17Bold(
                                        dialogContext,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$total ${AppLocalizations.of(dialogContext)!.syp}",
                                    textAlign: TextAlign.end,
                                    style: AppTextStyles.text17Bold(
                                      dialogContext,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: Text(
                            AppLocalizations.of(dialogContext)!.confirm,
                            style: AppTextStyles.text15white(
                              dialogContext,
                            ),
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

  Widget _buildFeeRow({
    required BuildContext context,
    required String serviceName,
    required int price,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              serviceName.isEmpty ? "--" : serviceName,
              softWrap: true,
              textAlign: TextAlign.start,
              style: AppTextStyles.text15(context),
            ),
          ),
          const SizedBox(width: 30),
          Flexible(
            child: Text(
              "$price ${AppLocalizations.of(context)!.syp}",
              textAlign: TextAlign.end,
              softWrap: true,
              style: AppTextStyles.text15(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: AppColors.text(context).withValues(alpha: 0.2),
    );
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
            child: Text(
              title,
              style: AppTextStyles.text15(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.text15(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8,
                sigmaY: 8,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.text(dialogContext).withValues(alpha: 0.1),
                    width: 1,
                  ),
                  color: Colors.white30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(dialogContext)!.logout,
                      style: AppTextStyles.text17Bold(dialogContext),
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(dialogContext).height * 0.02,
                    ),
                    Text(
                      AppLocalizations.of(dialogContext)!.confirm_logout,
                      style: AppTextStyles.text15(dialogContext),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green.withValues(alpha: 0.6),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            onPressed: () => Navigator.pop(
                              dialogContext,
                              true,
                            ),
                            child: Text(
                              AppLocalizations.of(
                                dialogContext,
                              )!
                                  .confirm,
                              style: AppTextStyles.text15white(
                                dialogContext,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white30,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => Navigator.pop(
                              dialogContext,
                              false,
                            ),
                            child: Text(
                              AppLocalizations.of(
                                dialogContext,
                              )!
                                  .cancel,
                              style: AppTextStyles.text15(
                                dialogContext,
                              ),
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

    setState(() => _isLoading = true);

    try {
      final success = await context.read<LoginController>().logout();

      if (!success) {
        throw Exception("Logout failed");
      }

      if (!mounted) return;

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
      if (!mounted) return;

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
        setState(() => _isLoading = false);
      }
    }
  }
}
