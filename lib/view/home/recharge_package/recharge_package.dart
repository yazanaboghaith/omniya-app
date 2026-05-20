import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_background.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/view/home/recharge_package/controller/recharge_package_controller.dart';

class RechargePackage extends StatefulWidget {
  const RechargePackage({super.key});

  @override
  State<RechargePackage> createState() => _RechargePackageState();
}

class _RechargePackageState extends State<RechargePackage> {
  bool isPrepaid = true;
  bool isBuying = false;
  final RechargePackageController controller = RechargePackageController();

  @override
  void initState() {
    super.initState();
    debugPrint(" فتح صفحة الباقات...");
    controller.getallpackage();

    controller.addListener(() {
      debugPrint(" تحديث UI من السيرفر");
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, screenWidth),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await controller.getallpackage(refresh: true);
                        },
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                            ),
                            child: Column(
                              children: [
                                _buildToggleButtons(context, screenWidth),
                                SizedBox(height: screenWidth * 0.04),
                                _buildInfoBox(context, screenWidth),
                                SizedBox(height: screenWidth * 0.05),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 60),
                                  child: _buildPackagesGrid(
                                    context,
                                    screenWidth,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // if (controller.isLoading && !isBuying) _buildLoading(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.04,
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: AppColors.text(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.text(context),
                size: screenWidth * 0.045,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Text(
            "شحن باقة",
            style: AppTextStyles.text24(
              context,
              color: AppColors.text(context),
            ).copyWith(fontSize: screenWidth * 0.06),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons(BuildContext context, double screenWidth) {
    return Container(
      width: double.infinity,
      height: screenWidth * 0.12,
      decoration: BoxDecoration(
        color: AppColors.text(context).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.text(context).withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isPrepaid = true;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isPrepaid
                      ? AppColors.text(context).withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  "مسبقة الدفع",
                  style: TextStyle(
                    color: isPrepaid
                        ? AppColors.text(context)
                        : AppColors.grey(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isPrepaid = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !isPrepaid
                      ? AppColors.text(context).withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  "لاحقة الدفع",
                  style: TextStyle(
                    color: !isPrepaid
                        ? AppColors.text(context)
                        : AppColors.grey(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        color: AppColors.text(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.text(context).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.secondary),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Center(
              child: Text(
                "يرجى التأكد من الرصيد قبل الشراء",
                style: AppTextStyles.text15(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesGrid(BuildContext context, double screenWidth) {
    final data = controller.data;
    final prepaid = data?.prepaid ?? [];
    final postpaid = data?.postpaid;
    final items = isPrepaid ? prepaid : (postpaid != null ? [postpaid] : []);

    // if (controller.isLoading && !isBuying) {
    //   debugPrint(" loading...");
    //   return const Center(child: CircularProgressIndicator());
    // }

    if (items.isEmpty) {
      debugPrint(" empty");
      return const Center(child: Text("لا توجد باقات"));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: screenWidth * 0.04,
        mainAxisSpacing: screenWidth * 0.04,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.text(context).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppColors.text(context).withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.quota,
                textAlign: TextAlign.center,
                style: AppTextStyles.text19Bold(context),
              ),
              const SizedBox(height: 10),
              Text(
                item.regPrice,
                textAlign: TextAlign.center,
                style: AppTextStyles.text15Grey(context),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.034),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.text(
                        context,
                      ).withValues(alpha: 0.3),
                      foregroundColor: AppColors.text(context),
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      showConfirmDialog(context, item.quota, item.id);
                    },
                    child: Text(
                      "شراء الآن",
                      style: AppTextStyles.text15(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildLoading() {
  //   return Positioned.fill(
  //     child: Container(
  //       color: Colors.black.withValues(alpha: 0.4),
  //       child: Center(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CircularProgressIndicator(color: AppColors.text(context)),
  //             const SizedBox(height: 15),
  //             Text(
  //               "جاري جلب الباقات...",
  //               style: TextStyle(color: AppColors.text(context)),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> showConfirmDialog(
    BuildContext pageContext,
    String quota,
    int addonId,
  ) {
    bool dialogLoading = false;
    bool showResult = false;
    bool isSuccess = false;
    String resultMessage = "";

    return showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Dialog(
                backgroundColor: AppColors.text(
                  context,
                ).withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showResult) ...[
                        Icon(
                          isSuccess
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          color: isSuccess ? Colors.green : Colors.redAccent,
                          size: 60,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          resultMessage,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.text15(context),
                        ),
                      ] else if (dialogLoading) ...[
                        CircularProgressIndicator(
                          color: AppColors.text(context),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "جاري تفعيل الباقة...",
                          style: TextStyle(color: AppColors.text(context)),
                        ),
                      ] else ...[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: MediaQuery.of(context).size.width * 0.26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppColors.text(
                                context,
                              ).withValues(alpha: 0.15),
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
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              "assets/images/icon.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Text(
                          "هل أنت متأكد من شراء باقة",
                          style: AppTextStyles.text15(context),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                        Text(quota, style: AppTextStyles.text19Bold(context)),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                onPressed: () async {
                                  setDialogState(() {
                                    dialogLoading = true;
                                  });

                                  isBuying = true;

                                  String apiMessage = await controller
                                      .chargeExtraPackage(
                                        addonId: addonId,
                                        postPaid: isPrepaid ? "1" : "0",
                                      );
                                  bool success =
                                      controller.state == PackageState.success;

                                  setDialogState(() {
                                    dialogLoading = false;
                                    showResult = true;
                                    isSuccess = success;
                                    resultMessage = success
                                        ? "تم تفعيل الباقة بنجاح!"
                                        : apiMessage;
                                  });

                                  isBuying = false;

                                  await Future.delayed(
                                    const Duration(seconds: 3),
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  "تأكيد",
                                  style: AppTextStyles.text15(context),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryText,
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "إلغاء",
                                  style: AppTextStyles.text15(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
