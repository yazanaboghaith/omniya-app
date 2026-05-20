import 'dart:async';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_background.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/const/app_notifier.dart';
import 'package:omniya/model/bank_model.dart';
import 'package:omniya/model/transactions_model.dart';
import 'package:omniya/view/home/payment_screen/controller/payment_screen_controller.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentBankController bankController = PaymentBankController();
  final TextEditingController refNoController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  BankModel? selectedBank;
  int? selectedBankId;
  String? selectedBankName;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      bankController.getBanks(),
      bankController.getTransactions(),
    ]);

    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    refNoController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return AppBackground(
      showHeader: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: () async {
            await _loadData();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: w * 0.02,
            ),
            child: Column(
              children: [
                SizedBox(height: w * 0.05),
                _buildAddPaymentCard(w, context),
                SizedBox(height: w * 0.05),
                AnimatedBuilder(
                  animation: bankController,
                  builder: (context, _) {
                    return _buildPaymentsReportCard(w, context);
                  },
                ),
                SizedBox(height: w * 0.25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPaymentCard(double w, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.05),
      decoration: _glassDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("إضافة دفعة بنك", style: AppTextStyles.text19Bold(context)),
          SizedBox(height: w * 0.04),

          Text("اسم البنك", style: AppTextStyles.text15(context)),
          SizedBox(height: 6),
          AnimatedBuilder(
            animation: bankController,
            builder: (context, _) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.text(context).withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.text(context).withValues(alpha: 0.15),
                  ),
                ),
                child: bankController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Material(
                        color: Colors.transparent,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<BankModel>(
                            isExpanded: true,
                            value: selectedBank,
                            hint: Text(
                              "اختر البنك",
                              style: TextStyle(color: AppColors.text(context)),
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.text(context),
                            ),
                            dropdownColor: isDark
                                ? AppColors.secondary
                                : AppColors.secondary,

                            items: bankController.banks.map((bank) {
                              return DropdownMenuItem(
                                value: bank,
                                child: Center(
                                  child: Text(
                                    bank.nameAr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedBank = value;
                                selectedBankId = value?.id;
                                selectedBankName = value?.nameAr;
                              });
                              debugPrint("ID: $selectedBankId");
                              debugPrint("NAME: $selectedBankName");
                            },
                          ),
                        ),
                      ),
              );
            },
          ),
          SizedBox(height: w * 0.04),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  context,
                  w,
                  "رقم الاشعار",
                  "مثال: 992311",
                  refNoController,
                  TextInputType.number,
                ),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: _buildInput(
                  context,
                  w,
                  "القيمة (ل.س)",
                  "مثال: 5000",
                  amountController,
                  TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.06),
          SizedBox(
            width: double.infinity,
            height: w * 0.12,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grey(
                  context,
                ).withValues(alpha: isDark ? 0.5 : 0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),

              onPressed: bankController.isSendingPayment
                  ? null
                  : () async {
                      if (selectedBankId == null) {
                        AppNotifier.instance.error(
                          context,
                          "يرجى اختيار اسم البنك",
                        );
                        return;
                      }

                      if (refNoController.text.trim().isEmpty ||
                          amountController.text.trim().isEmpty) {
                        AppNotifier.instance.error(
                          context,
                          "يرجى تعبأة جميع الحقول",
                        );
                        return;
                      }

                      final success = await bankController.addBankPayment(
                        bankId: selectedBankId!,
                        amount: amountController.text.trim(),
                        bankRefNo: refNoController.text.trim(),
                        context: context,
                      );

                      if (success) {
                        refNoController.clear();
                        amountController.clear();

                        setState(() {
                          selectedBank = null;
                          selectedBankId = null;
                          selectedBankName = null;
                        });
                      }
                    },

              child: bankController.isSendingPayment
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "إضافة دفعة",
                      style: AppTextStyles.text17Bold(context),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    BuildContext context,
    double w,
    String label,
    String hint,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.text15(context)),
        const SizedBox(height: 6),

        TextField(
          keyboardType: keyboardType,
          controller: controller,
          style: TextStyle(color: AppColors.text(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.text(context).withValues(alpha: 0.5),
              fontSize: 13,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.text(context).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.01),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(
                color: AppColors.text(context).withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsReportCard(double w, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 45),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(w * 0.05),
        decoration: _glassDecoration(context),
        child: AnimatedBuilder(
          animation: bankController,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("تقرير الدفعات", style: AppTextStyles.text17Bold(context)),
                SizedBox(height: w * 0.04),
                _buildSearchField(context),
                SizedBox(height: w * 0.04),

                if (bankController.isLoadingTransactions)
                  const Center(child: CircularProgressIndicator())
                else if (bankController.transactions.isEmpty)
                  const Text("لا يوجد بيانات")
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bankController.transactions.length,
                    itemBuilder: (context, index) {
                      final item = bankController.transactions[index];
                      return _buildPaymentItemFromApi(w, context, item);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 200), () {
          if (!mounted) return;

          bankController.getTransactions(search: value.trim());
        });
      },
      style: TextStyle(color: AppColors.text(context)),
      decoration: InputDecoration(
        hintText: "بحث...",
        hintStyle: TextStyle(
          color: AppColors.text(context).withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.text(context).withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.01),
        prefixIcon: Icon(Icons.search, color: AppColors.text(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildPaymentItemFromApi(
    double w,
    BuildContext context,
    TransactionModel item,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAccepted =
        item.status == "مقبول" ||
        item.status == "approved" ||
        item.status == "1";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.text(context).withValues(alpha: 0.15),
        ),
        color: isDark
            ? AppColors.text(context).withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Invoice Payment", style: AppTextStyles.text17Bold(context)),
              Text("رقم: 13953361", style: AppTextStyles.text13Grey(context)),
              Text("2026-04-20", style: AppTextStyles.text13Grey(context)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("10 ل.س", style: AppTextStyles.text17Bold(context)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAccepted
                      ? Colors.green.withValues(alpha: 0.6)
                      : Colors.red.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAccepted ? "مقبول" : "مرفوض",
                  style: AppTextStyles.text13(context),
                ),
              ),
            ],
          ),
        ],
      ),
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
