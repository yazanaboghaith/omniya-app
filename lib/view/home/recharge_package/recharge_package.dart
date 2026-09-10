import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omniya/core/const/app_background.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const String _successSound = 'sounds/success.mp3';
  static const String _errorSound = 'sounds/error.mp3';

  static const MethodChannel _vibrationChannel =
      MethodChannel('omniya_vibration');
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
    _audioPlayer.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _playSuccessFeedback() async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource(_successSound),
      );

      await _vibrationChannel.invokeMethod('strongVibrate');

      debugPrint(
        '[Recharge Package] Success sound and vibration played',
      );
    } catch (e) {
      debugPrint(
        '[Recharge Package] Error playing success feedback: $e',
      );
    }
  }

  Future<void> _playErrorFeedback() async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource(_errorSound),
      );

      await _vibrationChannel.invokeMethod('errorVibrate');

      debugPrint(
        '[Recharge Package] Error sound and vibration played',
      );
    } catch (e) {
      debugPrint(
        '[Recharge Package] Error playing error feedback: $e',
      );
    }
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
            AppLocalizations.of(context)!.recharge_package,
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
                  AppLocalizations.of(context)!.prepaid,
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
                  AppLocalizations.of(context)!.postpaid,
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
          SizedBox(width: screenWidth * 0.02),
          Icon(Icons.info_outline, color: AppColors.text(context)),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.check_balance_before_purchase,
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
    final postpaid = data?.postpaid ?? [];

    final items = isPrepaid ? prepaid : postpaid;

    debugPrint(
      '[Packages UI] Type: ${isPrepaid ? "PREPAID" : "POSTPAID"}',
    );

    debugPrint(
      '[Packages UI] Items count: ${items.length}',
    );

    if (items.isEmpty) {
      debugPrint('[Packages UI] No packages found');

      return Center(
        child: Text(
          AppLocalizations.of(context)!.no_packages,
        ),
      );
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

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width * 0.07,
            ),
            border: Border.all(
              color: AppColors.text(context).withValues(alpha: 0.15),
            ),
            color: isDark
                ? AppColors.text(context).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.034,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withValues(alpha: 0.6),
                      foregroundColor: AppColors.text(context),
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      debugPrint(
                        '[Packages UI] Selected package',
                      );

                      debugPrint(
                        '[Packages UI] Type: '
                        '${isPrepaid ? "PREPAID" : "POSTPAID"}',
                      );

                      debugPrint(
                        '[Packages UI] ID: ${item.id}',
                      );

                      debugPrint(
                        '[Packages UI] Quota: ${item.quota}',
                      );

                      showConfirmDialog(
                        context,
                        item.quota,
                        item.id,
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.buy_package,
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
                backgroundColor: Colors.white30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showResult) ...[
                        Center(
                          child: Icon(
                            isSuccess
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: isSuccess
                                ? Colors.green.withValues(alpha: 0.6)
                                : Colors.red.withValues(alpha: 0.6),
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Text(
                            resultMessage,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.text15(context),
                          ),
                        ),
                      ] else if (dialogLoading) ...[
                        Center(
                          child: CircularProgressIndicator(
                            color: AppColors.text(context),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          AppLocalizations.of(context)!.activating_package,
                          style: TextStyle(color: AppColors.text(context)),
                        ),
                      ] else ...[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Text(
                          AppLocalizations.of(context)!.buy_package,
                          style: AppTextStyles.text17Bold(context),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.confirm_buy_package,
                              style: AppTextStyles.text15(context),
                            ),
                            Center(
                              child: Text(
                                quota,
                                style: AppTextStyles.text19Bold(context),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green.withValues(alpha: 0.6),
                                ),
                                onPressed: () async {
                                  setDialogState(() {
                                    dialogLoading = true;
                                  });
                                  isBuying = true;
                                  debugPrint("Selected Package => "
                                      "${isPrepaid ? "PREPAID" : "POSTPAID"}");
                                  debugPrint("Addon ID => $addonId");
                                  String apiMessage =
                                      await controller.chargeExtraPackage(
                                    addonId: addonId,
                                    isPostPaid: !isPrepaid,
                                  );
                                  bool success =
                                      controller.state == PackageState.success;

                                  setDialogState(() {
                                    dialogLoading = false;
                                    showResult = true;
                                    isSuccess = success;
                                    resultMessage = success
                                        ? AppLocalizations.of(context)!
                                            .package_activated_success
                                        : apiMessage;
                                  });

                                  if (success) {
                                    await _playSuccessFeedback();
                                  } else {
                                    await _playErrorFeedback();
                                  }
                                  isBuying = false;

                                  await Future.delayed(
                                    const Duration(seconds: 3),
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.confirm,
                                  style: AppTextStyles.text15white(context),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white30,
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
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
