import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/bank_model.dart';
import 'package:omniya/model/payment_methods_response.dart';
import 'package:omniya/view/home/payment_screen/const/custom_glass_dropdown.dart';
import 'package:omniya/view/home/payment_screen/controller/bank_controller.dart';
import 'package:omniya/view/home/payment_screen/controller/payment_screen_controller.dart';

class AddBankPaymentCard extends StatelessWidget {
  final PaymentBankController bankController;
  final TextEditingController refNoController;
  final TextEditingController amountController;
  final BankModel? selectedBank;
  final ValueChanged<BankModel?> onBankChanged;
  final VoidCallback onSubmit;
  final bool isFormValid;
  const AddBankPaymentCard({
    super.key,
    required this.bankController,
    required this.refNoController,
    required this.amountController,
    required this.selectedBank,
    required this.onBankChanged,
    required this.onSubmit,
    required this.isFormValid,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.05 < 24 ? w * 0.05 : 24),
      decoration: _glassDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.add_Bank_Payment,
              style: AppTextStyles.text19Bold(context)),
          SizedBox(height: w * 0.04),
          Text(AppLocalizations.of(context)!.bank_Name,
              style: AppTextStyles.text15(context)),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: bankController,
            builder: (context, _) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
                child: bankController.isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : CustomGlassDropdown<BankModel>(
                        isLoading: bankController.isLoading,
                        items: bankController.banks,
                        selectedItem: selectedBank,
                        hint: AppLocalizations.of(context)!.select_Bank,
                        itemAsString: (bank) => bank.nameAr,
                        onChanged: onBankChanged,
                      ),
              );
            },
          ),
          SizedBox(height: w * 0.04),
          Row(
            children: [
              Expanded(
                child: _CustomInputField(
                  label: AppLocalizations.of(context)!.notification_Number,
                  hint: AppLocalizations.of(context)!.example_Number,
                  controller: refNoController,
                ),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: _CustomInputField(
                  label: AppLocalizations.of(context)!.amount,
                  hint: AppLocalizations.of(context)!.example_Amount,
                  controller: amountController,
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.06),
          SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid
                      ? Colors.green.withValues(alpha: 0.6)
                      : Colors.grey.withValues(alpha: 0.15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: isFormValid ? onSubmit : null,
                child: Text(
                  AppLocalizations.of(context)!.submit_Payment,
                ),
              )),
        ],
      ),
    );
  }
}

class _CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _CustomInputField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.text15(context)),
        const SizedBox(height: 6),
        TextField(
          keyboardType: TextInputType.number,
          controller: controller,
          style: TextStyle(color: AppColors.text(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: AppColors.text(context).withValues(alpha: 0.5),
                fontSize: 13),
            filled: true,
            fillColor: isDark
                ? AppColors.text(context).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.01),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(
                  color: AppColors.text(context).withValues(alpha: 0.15)),
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
}

class OnlinePaymentGateways extends StatelessWidget {
  final Bankcontroller paymentMethodsController;
  final ValueChanged<PaymentMethod> onGatewayTap;

  const OnlinePaymentGateways({
    super.key,
    required this.paymentMethodsController,
    required this.onGatewayTap,
  });

  @override
  Widget build(BuildContext context) {
    final gateways = paymentMethodsController.methods;

    if (paymentMethodsController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gateways.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_payment_gateways));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gateways.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        final item = gateways[index];
        return GestureDetector(
          onTap: () => onGatewayTap(item),
          child: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Image.network(
                  item.icon,
                  width: 35,
                  height: 35,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.payment, size: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(item.name, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        );
      },
    );
  }
}

BoxDecoration _glassDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  double w = MediaQuery.of(context).size.width;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(w * 0.07),
    border: Border.all(
        width: 1, color: AppColors.text(context).withValues(alpha: 0.1)),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8)),
      BoxShadow(
          color: Colors.white.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2)),
    ],
    color: isDark
        ? AppColors.text(context).withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04),
  );
}
