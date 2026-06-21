import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:omniya/const/app_color.dart';

class PaymentTabsWidget extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;

  const PaymentTabsWidget({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      height: w * 0.12,
      decoration: BoxDecoration(
        color: AppColors.text(context).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
        border:
            Border.all(color: AppColors.text(context).withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onMethodChanged("online"),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedMethod == "online"
                      ? AppColors.text(context).withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  "الدفع الإلكتروني",
                  style: TextStyle(
                    color: selectedMethod == "online"
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
              onTap: () => onMethodChanged("bank"),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedMethod == "bank"
                      ? AppColors.text(context).withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  "تحويل بنكي",
                  style: TextStyle(
                    color: selectedMethod == "bank"
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
}
