import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/bank_model.dart';
import 'package:omniya/model/payment_methods_response.dart';
import 'package:omniya/view/home/payment_screen/controller/bank_controller.dart';

class PaymentDialogs {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static const String _successSound = 'sounds/success.mp3';
  static const String _errorSound = 'sounds/error.mp3';
  static const MethodChannel _vibrationChannel =
      MethodChannel('omniya_vibration');

  static Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource(_successSound),
      );

      await _vibrationChannel.invokeMethod('strongVibrate');

      debugPrint('After vibration');
      debugPrint('Success payment sound and vibration played');
    } catch (e) {
      debugPrint(
        'Error playing success sound/vibration: $e',
      );
    }
  }

  static Future<void> _playErrorSound() async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        AssetSource(_errorSound),
      );

      await _vibrationChannel.invokeMethod('errorVibrate');

      debugPrint('Error vibration executed');
      debugPrint('Error payment sound and vibration played');
    } catch (e) {
      debugPrint(
        'Error playing error sound/vibration: $e',
      );
    }
  }

  static Future<void> showGatewayPaymentDialog({
    required BuildContext context,
    required PaymentMethod method,
    required Bankcontroller paymentController,
    required Future<bool> Function() hasInternetConnection,
    required void Function() showConnectionError,
    required void Function(String msg) log,
    required void Function() onWentToGateway,
  }) async {
    final TextEditingController amountCtrl = TextEditingController();

    bool loading = false;

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
            constraints: const BoxConstraints(
              maxWidth: 420,
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
                      color: Colors.white.withValues(
                        alpha: 0.15,
                      ),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              Colors.white.withValues(
                                alpha: 0.20,
                              ),
                              Colors.white.withValues(
                                alpha: 0.12,
                              ),
                            ]
                          : [
                              Colors.white.withValues(
                                alpha: 0.30,
                              ),
                              Colors.white.withValues(
                                alpha: 0.18,
                              ),
                            ],
                    ),
                  ),
                  child: StatefulBuilder(
                    builder: (
                      context,
                      setStateDialog,
                    ) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .enter_payment_amount,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.text17Bold(
                                context,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            '${AppLocalizations.of(context)!.gateway}: '
                            '${method.name}',
                            style: AppTextStyles.text15(
                              context,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextField(
                            controller: amountCtrl,
                            keyboardType: TextInputType.number,
                            enabled: !loading,
                            style: AppTextStyles.text15(
                              context,
                            ),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(
                                context,
                              )!
                                  .amount,
                              labelStyle: AppTextStyles.text15(
                                context,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(
                                alpha: 0.12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (loading)
                            const Padding(
                              padding: EdgeInsets.only(
                                top: 20,
                              ),
                              child: Center(
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 24,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white30,
                                    foregroundColor: Colors.black87,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        18,
                                      ),
                                    ),
                                  ),
                                  onPressed: loading
                                      ? null
                                      : () {
                                          Navigator.pop(
                                            dialogContext,
                                          );
                                        },
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!
                                        .cancel,
                                    style: AppTextStyles.text15(
                                      context,
                                    ).copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.withValues(
                                      alpha: 0.6,
                                    ),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        18,
                                      ),
                                    ),
                                  ),
                                  onPressed: loading
                                      ? null
                                      : () async {
                                          final amount = amountCtrl.text.trim();

                                          if (amount.isEmpty) {
                                            return;
                                          }

                                          final hasInternet =
                                              await hasInternetConnection();

                                          if (!hasInternet) {
                                            if (Navigator.canPop(
                                              dialogContext,
                                            )) {
                                              Navigator.pop(
                                                dialogContext,
                                              );
                                            }

                                            showConnectionError();
                                            return;
                                          }

                                          setStateDialog(
                                            () {
                                              loading = true;
                                            },
                                          );

                                          log(
                                            'Creating payment...',
                                          );

                                          log(
                                            'Amount => $amount',
                                          );

                                          log(
                                            'Gateway => ${method.value}',
                                          );

                                          try {
                                            final success =
                                                await paymentController
                                                    .createPayment(
                                              amount: amount,
                                              paymentType: method.value,
                                            );

                                            if (!success) {
                                              setStateDialog(
                                                () {
                                                  loading = false;
                                                },
                                              );

                                              log(
                                                'Payment creation failed',
                                              );

                                              return;
                                            }

                                            final session =
                                                paymentController.session;

                                            log(
                                              'Transaction ID => '
                                              '${session.transactionId}',
                                            );

                                            log(
                                              'URL => '
                                              '${session.paymentUrl}',
                                            );

                                            session.isActive = true;

                                            onWentToGateway();

                                            Navigator.pop(
                                              dialogContext,
                                            );

                                            await paymentController
                                                .openPaymentUrl();

                                            log(
                                              'Browser opened',
                                            );
                                          } catch (e) {
                                            log(
                                              'Create payment error => $e',
                                            );

                                            setStateDialog(
                                              () {
                                                loading = false;
                                              },
                                            );
                                          }
                                        },
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!
                                        .confirm_payment,
                                    style: AppTextStyles.text15(
                                      context,
                                    ).copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    amountCtrl.dispose();
  }

  static Future<void> showConfirmDialog({
    required BuildContext context,
    required BankModel? bank,
    required String amount,
    required String refNo,
    required Future<void> Function() submitBankPayment,
  }) async {
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
            constraints: const BoxConstraints(
              maxWidth: 420,
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
                      color: Colors.white.withValues(
                        alpha: 0.15,
                      ),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              Colors.white.withValues(
                                alpha: 0.20,
                              ),
                              Colors.white.withValues(
                                alpha: 0.12,
                              ),
                            ]
                          : [
                              Colors.white.withValues(
                                alpha: 0.30,
                              ),
                              Colors.white.withValues(
                                alpha: 0.18,
                              ),
                            ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          AppLocalizations.of(
                            dialogContext,
                          )!
                              .confirm_payment,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.text17Bold(
                            dialogContext,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildInfoRow(
                        context: dialogContext,
                        title: AppLocalizations.of(
                          dialogContext,
                        )!
                            .bank_Name,
                        value: bank?.nameAr ?? '',
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _buildInfoRow(
                        context: dialogContext,
                        title: AppLocalizations.of(
                          dialogContext,
                        )!
                            .total_Amount,
                        value: amount,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _buildInfoRow(
                        context: dialogContext,
                        title: AppLocalizations.of(
                          dialogContext,
                        )!
                            .notification_Number,
                        value: refNo,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white30,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    18,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                );
                              },
                              child: Text(
                                AppLocalizations.of(
                                  dialogContext,
                                )!
                                    .cancel,
                                style: AppTextStyles.text15(
                                  dialogContext,
                                ).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.withValues(
                                  alpha: 0.6,
                                ),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    18,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(
                                  dialogContext,
                                );

                                await submitBankPayment();

                                await _playSuccessSound();
                              },
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

  static Widget _buildInfoRow({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: AppTextStyles.text15(
              context,
            ).copyWith(
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
            style: AppTextStyles.text15(
              context,
            ),
          ),
        ),
      ],
    );
  }

  static BoxDecoration glassDialogDecoration(
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withValues(
          alpha: 0.15,
        ),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.25,
          ),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                Colors.white.withValues(
                  alpha: 0.20,
                ),
                Colors.white.withValues(
                  alpha: 0.12,
                ),
              ]
            : [
                Colors.white.withValues(
                  alpha: 0.30,
                ),
                Colors.white.withValues(
                  alpha: 0.18,
                ),
              ],
      ),
    );
  }
}
