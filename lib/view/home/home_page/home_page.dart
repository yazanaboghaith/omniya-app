import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/l10n/app_localizations.dart';
import 'package:omniya/view/home/const/consumption_gauge.dart';
import 'package:omniya/view/home/const/speedometer.dart';
import 'package:omniya/view/home/home_page/controller/home_page_controller.dart';
import 'package:omniya/view/home/recharge_package/recharge_package.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<HomePageController>().getUserDetails();
    });
  }

  bool isRefreshing = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final controller = context.watch<HomePageController>();
    final user = controller.user;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          if (!mounted) return;
          await context.read<HomePageController>().getUserDetails();
        },
        child: _buildHomeContent(controller, user, w, h),
      ),
    );
  }

  Widget _buildHomeContent(
    HomePageController controller,
    dynamic user,
    double w,
    double h,
  ) {
    if (controller.state == HomeState.loading && user == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (controller.state == HomeState.noInternet) {
      return _buildErrorWidget(
        icon: Icons.wifi_off_rounded,
        title: AppLocalizations.of(context)!.no_Internet,
        message: controller.errorMessage,
        onRetry: () => controller.getUserDetails(),
        w: w,
      );
    }

    if (controller.state == HomeState.serverError) {
      return _buildErrorWidget(
        icon: Icons.dns_rounded,
        title: AppLocalizations.of(context)!.server_Error,
        message: controller.errorMessage,
        onRetry: () => controller.getUserDetails(),
        w: w,
      );
    }

    if (controller.state == HomeState.unexpectedError) {
      return _buildErrorWidget(
        icon: Icons.error_outline_rounded,
        title: AppLocalizations.of(context)!.error,
        message: controller.errorMessage,
        onRetry: () async {
          setState(() => isRefreshing = true);

          await context.read<HomePageController>().getUserDetails();

          if (!mounted) return;
          setState(() => isRefreshing = false);
        },
        w: w,
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: 10,
        left: w * 0.05,
        right: w * 0.05,
        bottom: 20,
      ),
      child: Column(
        children: [
          _buildBalanceCard(w, user),
          SizedBox(height: h * 0.02),
          _buildStatusRow(w, user),
          SizedBox(height: h * 0.02),
          _buildPrimaryPackageCard(w, user),
          SizedBox(height: h * 0.01),
          _buildAddonPackagesSection(w, user),
        ],
      ),
    );
  }

  Widget _buildErrorWidget({
    required IconData icon,
    required String title,
    required String message,
    required VoidCallback onRetry,
    required double w,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.symmetric(horizontal: w * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 75,
              color: AppColors.text(context).withValues(alpha: 0.6),
            ),
            SizedBox(height: w * 0.02),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.text19Bold(context),
            ),
            SizedBox(height: w * 0.02),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text(context).withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            SizedBox(height: w * 0.3),
            Center(
              child: ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryText,
                  foregroundColor: AppColors.text(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.text(context),
                ),
                label: Text(
                  AppLocalizations.of(context)!.retry,
                  style: TextStyle(color: AppColors.text(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double w, dynamic user) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(w * 0.06),
          decoration: _glassDecoration(context),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.current_Balance,
                  style: AppTextStyles.text20Grey(context)),
              SizedBox(height: w * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "${user?.balance ?? 0}",
                    style: AppTextStyles.text50(context),
                  ),
                  SizedBox(width: w * 0.01),
                  Text(AppLocalizations.of(context)!.currency,
                      style: AppTextStyles.text17Bold(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(double w, dynamic user) {
    final bool isUnlimited = user?.baseService?.unlimitted ?? false;

    debugPrint(
      'Unlimited => ${user?.baseService?.unlimitted}',
    );
    return Row(
      children: [
        Expanded(
          child: Container(
            height: w * 0.42,
            padding: EdgeInsets.symmetric(vertical: w * 0.04),
            decoration: _glassDecoration(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: w * 0.25,
                  child: Center(
                    child: isUnlimited
                        ? Icon(
                            Icons.all_inclusive,
                            size: w * 0.18,
                            color: AppColors.text(context),
                          )
                        : ConsumptionGauge(
                            value: (user?.quota?.totalUsagePercent ?? 0)
                                .toDouble(),
                          ),
                  ),
                ),
                SizedBox(height: w * 0.03),
                Text(
                  isUnlimited
                      ? AppLocalizations.of(context)!.unlimited_Subscription
                      : AppLocalizations.of(context)!.total_Usage,
                  style: AppTextStyles.text13Grey(context),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: w * 0.04),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: w * 0.04),
            decoration: _glassDecoration(context),
            child: Column(
              children: [
                SpeedometerWidget(
                  speedText: user?.quota?.currentSpeed ?? '',
                ),
                SizedBox(height: w * 0.01),
                Text(
                  AppLocalizations.of(context)!.current_Speed,
                  style: AppTextStyles.text13Grey(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryPackageCard(double w, dynamic user) {
    double totalQuota = (user?.baseService?.quota ?? 0).toDouble();
    double remainingQuota = (user?.quota?.remainingDefault ?? 0).toDouble();
    final bool isUnlimited = user?.baseService?.unlimitted ?? false;

    double progressPercent =
        totalQuota > 0 ? (remainingQuota / totalQuota) : 0.0;
    if (progressPercent > 1.0) progressPercent = 1.0;

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: _glassDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: w * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.basic_Package,
                  style: AppTextStyles.text17Bold(context),
                ),
                if (!isUnlimited)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: const RechargePackage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.03,
                        vertical: w * 0.025,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(w * 0.07),
                          border: Border.all(
                            color:
                                AppColors.text(context).withValues(alpha: 0.15),
                          ),
                          color: Colors.green.withValues(alpha: 0.6)),
                      child: Text(
                        AppLocalizations.of(context)!.recharge_Package,
                        style: AppTextStyles.text13BlackBold(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              // Expanded(
              //   child: Text(
              //     user?.baseService?.label ?? '',
              //     style: AppTextStyles.text15(context),
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // ),
            ],
          ),
          SizedBox(height: w * 0.05),
          Container(
            height: w * 0.02,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.text(context).withValues(alpha: 0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        color: AppColors.text(context).withValues(alpha: 0.05),
                      ),
                      Container(
                        width: isUnlimited
                            ? constraints.maxWidth
                            : constraints.maxWidth * progressPercent,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.speed],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: w * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${AppLocalizations.of(context)!.valid_Until} ${user?.expiryDate ?? '--'}",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.text10Grey(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isUnlimited
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.all_inclusive,
                            size: 16,
                            color: AppColors.grey(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!
                                .unlimited_Subscription,
                            style: AppTextStyles.text10Grey(context),
                          ),
                        ],
                      )
                    : Text(
                        "${AppLocalizations.of(context)!.remaining} ${user?.quota?.remainingDefault ?? 0} ${AppLocalizations.of(context)!.from} ${user?.baseService?.quota ?? 0} AppLocalizations.of(context)!.gigabyte",
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.left,
                        style: AppTextStyles.text10Grey(context),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddonPackagesSection(double w, dynamic user) {
    final packagesList = user?.packages ?? [];

    if (packagesList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: w * 0.04),
        Container(
          padding: EdgeInsets.all(w * 0.04),
          decoration: _glassDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.extra_Packages,
                style: AppTextStyles.text17Bold(context),
              ),
              SizedBox(height: w * 0.04),
              Column(
                children: List.generate(packagesList.length, (index) {
                  final package = packagesList[index];

                  final packagePercent =
                      ((package.packagePercent ?? 0).toDouble() / 100.0)
                          .clamp(0.0, 1.0);

                  return Container(
                    margin: EdgeInsets.only(
                      bottom: index == packagesList.length - 1 ? 0 : w * 0.04,
                    ),
                    padding: EdgeInsets.all(w * 0.03),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.text(context).withValues(alpha: 0.12),
                      ),
                      color: AppColors.text(context).withValues(alpha: 0.05),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name ??
                              AppLocalizations.of(context)!.extra_Package,
                          style: AppTextStyles.text15(context),
                        ),
                        SizedBox(height: w * 0.03),
                        Container(
                          height: w * 0.02,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                AppColors.text(context).withValues(alpha: 0.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      color: AppColors.text(context)
                                          .withValues(alpha: 0.05),
                                    ),
                                    Container(
                                      width:
                                          constraints.maxWidth * packagePercent,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.speed,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: w * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${AppLocalizations.of(context)!.valid_Until} ${package.expireAt ?? '--'}",
                              style: AppTextStyles.text10Grey(context),
                            ),
                            Text(
                              "${AppLocalizations.of(context)!.remaining} ${package.packageRemaining ?? 0} / ${package.packageLimit ?? 0}",
                              style: AppTextStyles.text10Grey(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _glassDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double w = MediaQuery.of(context).size.width;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(w * 0.07),
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
          ? AppColors.text(context).withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.04),
    );
  }
}
