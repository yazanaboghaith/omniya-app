import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:omniya/const/app_background.dart';
import 'package:omniya/const/app_color.dart';
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

    return AppBackground(
      showHeader: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () async {
                  if (!mounted) return;
                  await context.read<HomePageController>().getUserDetails();
                },
                child: _buildHomeContent(controller, user, w, h),
              ),
            ),
            if (isRefreshing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.text(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "جاري التحديث...",
                          style: TextStyle(color: AppColors.text(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
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
        title: 'لا يوجد اتصال بالإنترنت',
        message: controller.errorMessage,
        onRetry: () => controller.getUserDetails(),
        w: w,
      );
    }

    if (controller.state == HomeState.serverError) {
      return _buildErrorWidget(
        icon: Icons.dns_rounded,
        title: 'مشكلة في الاتصال بالخادم',
        message: controller.errorMessage,
        onRetry: () => controller.getUserDetails(),
        w: w,
      );
    }

    if (controller.state == HomeState.unexpectedError) {
      return _buildErrorWidget(
        icon: Icons.error_outline_rounded,
        title: 'تنبيه خطأ',
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
        left: w * 0.05,
        right: w * 0.05,
        bottom: w * 0.13,
      ),
      child: Column(
        children: [
          SizedBox(height: h * 0.03),
          _buildBalanceCard(w, user),
          SizedBox(height: h * 0.02),
          _buildStatusRow(w, user),
          SizedBox(height: h * 0.02),
          _buildPrimaryPackageCard(w, user),
          SizedBox(height: h * 0.02),
          _buildAddonPackagesSection(w, user),
          SizedBox(height: h * 0.12),
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
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.text19Bold(context),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text(context).withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
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
                  'إعادة المحاولة',
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
              Text("الرصيد الحالي", style: AppTextStyles.text20Grey(context)),
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
                  Text("ل.ج.س", style: AppTextStyles.text17Bold(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(double w, dynamic user) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: w * 0.04),
            decoration: _glassDecoration(context),
            child: Column(
              children: [
                ConsumptionGauge(
                  value: (user?.quota?.totalUsagePercent ?? 0).toDouble(),
                ),
                SizedBox(height: w * 0.01),
                Text(
                  "الاستهلاك الكلي",
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
                  speed: (user?.quota?.currentSpeedValue ?? 0).toDouble(),
                ),
                SizedBox(height: w * 0.01),
                Text(
                  "السرعة الحالية",
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

    double progressPercent = totalQuota > 0
        ? (remainingQuota / totalQuota)
        : 0.0;
    if (progressPercent > 1.0) progressPercent = 1.0;

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: _glassDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user?.baseService?.label ?? "الباقات الاساسية",
                style: AppTextStyles.text17Bold(context),
              ),
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
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.text(context).withValues(alpha: 0.3),
                  ),
                  child: Text(
                    "شحن باقة",
                    style: AppTextStyles.text13BlackBold(),
                  ),
                ),
              ),
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
                        width: constraints.maxWidth * progressPercent,
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
              Text(
                "صالحة لغاية ${user?.expiryDate ?? '--'}",
                textDirection: TextDirection.rtl,
                style: AppTextStyles.text10Grey(context),
              ),
              Text(
                "المتبقي ${user?.quota?.remainingDefault ?? 0} جيجا من اصل ${user?.baseService?.quota ?? 0} جيجا",
                textDirection: TextDirection.rtl,
                style: AppTextStyles.text10Grey(context),
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
        Padding(
          padding: EdgeInsets.only(bottom: w * 0.02),
          child: Text(
            "الباقات الاضافية",
            style: AppTextStyles.text17Bold(context),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: packagesList.length,
          itemBuilder: (context, index) {
            final package = packagesList[index];
            double packagePercent =
                ((package.packagePercent ?? 0).toDouble() / 100.0).clamp(
                  0.0,
                  1.0,
                );
            return Container(
              margin: EdgeInsets.only(bottom: w * 0.03),
              padding: EdgeInsets.all(w * 0.04),
              decoration: _glassDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name ?? "باقة إضافية",
                    style: AppTextStyles.text15(context),
                  ),
                  SizedBox(height: w * 0.04),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
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
                                  color: AppColors.text(
                                    context,
                                  ).withValues(alpha: 0.05),
                                ),
                                Container(
                                  width: constraints.maxWidth * packagePercent,
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
                  ),
                  SizedBox(height: w * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "صالحة لغاية ${package.expireAt ?? '--'}",
                        textDirection: TextDirection.rtl,
                        style: AppTextStyles.text10Grey(context),
                      ),
                      Text(
                        "المتبقي ${package.packageRemaining ?? 0} جيجا من اصل ${package.packageLimit ?? 0} جيجا",
                        textDirection: TextDirection.rtl,
                        style: AppTextStyles.text10Grey(context),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  BoxDecoration _glassDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: AppColors.text(context).withValues(alpha: 0.15),
        width: 1,
      ),
      gradient: LinearGradient(
        colors: [
          AppColors.text(context).withValues(alpha: 0.25),
          AppColors.text(context).withValues(alpha: 0.25),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
