import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_notifier.dart';
import 'package:omniya/core/const/connection_error_view.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/bank_model.dart';
import 'package:omniya/model/payment_methods_response.dart';

import 'package:omniya/view/home/payment_screen/addbank_payment_card.dart';
import 'package:omniya/view/home/payment_screen/controller/bank_controller.dart';
import 'package:omniya/view/home/payment_screen/controller/payment_screen_controller.dart';
import 'package:omniya/view/home/payment_screen/payment_tabs.dart';
import 'package:omniya/view/home/payment_screen/payments_report_card.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver {
  final PaymentBankController bankController = PaymentBankController();
  final Bankcontroller paymentController = Bankcontroller();
  final TextEditingController refNoController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  BankModel? selectedBank;
  int? selectedBankId;
  String? selectedBankName;
  String selectedMethod = "bank";
  bool _checkingPaymentUI = false;
  bool _isCheckingPayment = false;
  bool _wentToGateway = false;
  bool _pageLoading = true;
  bool _hasConnectionError = false;
  bool _loadingData = false;

  void _log(String msg) {
    debugPrint('[PAYMENT] $msg');
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  bool get isBankFormValid {
    return selectedBank != null &&
        refNoController.text.trim().isNotEmpty &&
        amountController.text.trim().isNotEmpty;
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(
        const Duration(seconds: 5),
      );

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (e) {
      _log('Internet check failed => $e');
      return false;
    }
  }

  Future<void> _loadData() async {
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted || _loadingData) {
      return;
    }

    setState(() {
      _loadingData = true;
      _pageLoading = true;
      _hasConnectionError = false;
    });

    try {
      final hasInternet = await _hasInternetConnection();

      if (!hasInternet) {
        _log('NO INTERNET CONNECTION');

        if (!mounted) {
          return;
        }

        setState(() {
          _pageLoading = false;
          _hasConnectionError = true;
        });

        return;
      }

      await Future.wait([
        bankController.getBanks(),
        bankController.getTransactions(page: 1),
        paymentController.getPaymentMethods(),
      ]);

      if (!mounted) {
        return;
      }

      final bankError = bankController.error;
      final paymentError = paymentController.error;

      _log('Bank error => $bankError');
      _log('Payment error => $paymentError');

      if (bankError != null || paymentError != null) {
        _log('INITIAL DATA FAILED');

        setState(() {
          _pageLoading = false;
          _hasConnectionError = true;
        });

        return;
      }

      setState(() {
        _pageLoading = false;
        _hasConnectionError = false;
      });

      _log('Initial payment data loaded successfully');
    } catch (e, stackTrace) {
      _log('Initial payment data error => $e');
      _log('$stackTrace');

      if (!mounted) {
        return;
      }

      setState(() {
        _pageLoading = false;
        _hasConnectionError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingData = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    _log('Lifecycle => $state');

    if (state != AppLifecycleState.resumed) {
      return;
    }

    final session = paymentController.session;

    if (!session.isActive ||
        session.transactionId == null ||
        _isCheckingPayment ||
        !_wentToGateway) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _checkingPaymentUI = true;
    });

    _checkPaymentAfterReturn();
  }

  Future<void> _checkPaymentAfterReturn() async {
    _isCheckingPayment = true;

    try {
      final hasInternet = await _hasInternetConnection();

      if (!hasInternet) {
        _showConnectionError();
        return;
      }

      final result = await paymentController.checkPayment();

      if (!mounted) {
        return;
      }

      AppNotifier.instance.show(
        context: context,
        title: result
            ? AppLocalizations.of(context)!.payment_success
            : AppLocalizations.of(context)!.payment_pending,
        message: result
            ? AppLocalizations.of(context)!.payment_confirmed_successfully
            : AppLocalizations.of(context)!.payment_not_confirmed_yet,
        isSuccess: result,
      );

      _resetSession();
    } catch (e) {
      _log('Check payment error => $e');

      if (mounted) {
        AppNotifier.instance.show(
          context: context,
          title: AppLocalizations.of(context)!.payment_error,
          message: AppLocalizations.of(context)!.payment_status_check_error,
          isSuccess: false,
        );
      }
    } finally {
      _isCheckingPayment = false;

      if (mounted) {
        setState(() {
          _checkingPaymentUI = false;
        });
      }
    }
  }

  void _showConnectionError() {
    if (!mounted) {
      return;
    }

    setState(() {
      _pageLoading = false;
      _hasConnectionError = true;
      _checkingPaymentUI = false;
    });
  }

  Future<void> _showGatewayPaymentDialog(
    PaymentMethod method,
  ) async {
    final TextEditingController amountCtrl = TextEditingController();

    bool loading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setStateDialog,
          ) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.enter_payment_amount,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.gateway}: '
                    '${method.name}',
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.amount,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                  ),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final amount = amountCtrl.text.trim();

                          if (amount.isEmpty) {
                            return;
                          }

                          final hasInternet = await _hasInternetConnection();

                          if (!hasInternet) {
                            if (Navigator.canPop(
                              dialogContext,
                            )) {
                              Navigator.pop(
                                dialogContext,
                              );
                            }

                            _showConnectionError();
                            return;
                          }

                          setStateDialog(() {
                            loading = true;
                          });

                          _log(
                            'Creating payment...',
                          );

                          _log(
                            'Amount => $amount',
                          );

                          _log(
                            'Gateway => ${method.value}',
                          );

                          try {
                            final success =
                                await paymentController.createPayment(
                              amount: amount,
                              paymentType: method.value,
                            );

                            if (!success) {
                              setStateDialog(() {
                                loading = false;
                              });

                              _log(
                                'Payment creation failed',
                              );

                              return;
                            }

                            final session = paymentController.session;

                            _log(
                              'Transaction ID => '
                              '${session.transactionId}',
                            );

                            _log(
                              'URL => '
                              '${session.paymentUrl}',
                            );

                            session.isActive = true;

                            _wentToGateway = true;

                            Navigator.pop(
                              dialogContext,
                            );

                            await paymentController.openPaymentUrl();

                            _log(
                              'Browser opened',
                            );
                          } catch (e) {
                            _log(
                              'Create payment error => $e',
                            );

                            setStateDialog(() {
                              loading = false;
                            });
                          }
                        },
                  child: Text(
                    AppLocalizations.of(context)!.confirm_payment,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    amountCtrl.dispose();
  }

  void _resetSession() {
    _log('Reset session');

    _wentToGateway = false;

    paymentController.session.clear();
  }

  Future<void> _showConfirmDialog() async {
    final bank = selectedBank;

    final amount = amountController.text.trim();

    final refNo = refNoController.text.trim();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white30,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _glassDialogDecoration(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.confirm_payment,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  '${AppLocalizations.of(context)!.bank_Name} '
                  '${bank?.nameAr ?? ''}',
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppLocalizations.of(context)!.total_Amount} '
                  '$amount',
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppLocalizations.of(context)!.notification_Number} '
                  '$refNo',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .cancel,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(
                            dialogContext,
                          );

                          await _submitBankPayment();
                        },
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .confirm,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _glassDialogDecoration(
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
                  alpha: 0.2,
                ),
                Colors.white.withValues(
                  alpha: 0.2,
                ),
              ]
            : [
                Colors.white.withValues(
                  alpha: 0.2,
                ),
                Colors.white.withValues(
                  alpha: 0.2,
                ),
              ],
      ),
    );
  }

  Future<void> _submitBankPayment() async {
    final hasInternet = await _hasInternetConnection();

    if (!hasInternet) {
      _showConnectionError();
      return;
    }

    if (!mounted || selectedBank == null) {
      return;
    }

    setState(() {
      _checkingPaymentUI = true;
    });

    try {
      final success = await bankController.addBankPayment(
        bankId: selectedBank!.id,
        amount: amountController.text.trim(),
        bankRefNo: refNoController.text.trim(),
        context: context,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        AppNotifier.instance.show(
          context: context,
          title: AppLocalizations.of(context)!.payment_completed,
          message: AppLocalizations.of(context)!.payment_sent_successfully,
          isSuccess: true,
        );

        refNoController.clear();
        amountController.clear();

        setState(() {
          selectedBank = null;
          selectedBankId = null;
          selectedBankName = null;
        });

        await bankController.getTransactions(
          page: 1,
        );
      } else {
        AppNotifier.instance.show(
          context: context,
          title: AppLocalizations.of(context)!.error,
          message: AppLocalizations.of(context)!.payment_send_failed,
          isSuccess: false,
        );
      }
    } catch (e) {
      _log(
        'Sending bank payment error => $e',
      );

      final hasInternet = await _hasInternetConnection();

      if (!hasInternet) {
        _showConnectionError();
        return;
      }

      if (mounted) {
        AppNotifier.instance.show(
          context: context,
          title: AppLocalizations.of(context)!.error,
          message: AppLocalizations.of(context)!.sending_error,
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _checkingPaymentUI = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    refNoController.dispose();
    amountController.dispose();

    bankController.dispose();
    paymentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_checkingPaymentUI,
      child: SafeArea(
        child: Stack(
          children: [
            if (_pageLoading)
               PageLoadingView(
                message: AppLocalizations.of(context)!.loading_payment_data,
              )
            else if (_hasConnectionError)
              ConnectionErrorView(
                isLoading: _loadingData,
                onRetry: _loadInitialData,
              )
            else
              RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      PaymentTabsWidget(
                        selectedMethod: selectedMethod,
                        onMethodChanged: (m) {
                          setState(() {
                            selectedMethod = m;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (selectedMethod == "bank")
                        AddBankPaymentCard(
                          isFormValid: isBankFormValid,
                          bankController: bankController,
                          refNoController: refNoController,
                          amountController: amountController,
                          selectedBank: selectedBank,
                          onBankChanged: (value) {
                            setState(() {
                              selectedBank = value;
                              selectedBankId = value?.id;
                              selectedBankName = value?.nameAr;
                            });
                          },
                          onSubmit: () async {
                            if (!isBankFormValid) {
                              AppNotifier.instance.show(
                                context: context,
                                title: AppLocalizations.of(
                                  context,
                                )!
                                    .missing_data_title,
                                message: AppLocalizations.of(
                                  context,
                                )!
                                    .missing_data_message,
                                isSuccess: false,
                              );

                              return;
                            }

                            await _showConfirmDialog();
                          },
                        )
                      else
                        AnimatedBuilder(
                          animation: paymentController,
                          builder: (context, _) {
                            return OnlinePaymentGateways(
                              paymentMethodsController: paymentController,
                              onGatewayTap: _showGatewayPaymentDialog,
                            );
                          },
                        ),
                      const SizedBox(
                        height: 30,
                      ),
                      AnimatedBuilder(
                        animation: bankController,
                        builder: (context, _) {
                          return PaymentsReportCard(
                            bankController: bankController,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (_checkingPaymentUI)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
