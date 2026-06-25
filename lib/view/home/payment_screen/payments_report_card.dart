import 'dart:async';
import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/model/transactions_model.dart';
import 'package:omniya/view/home/payment_screen/controller/payment_screen_controller.dart';

class PaymentsReportCard extends StatefulWidget {
  final PaymentBankController bankController;

  const PaymentsReportCard({super.key, required this.bankController});

  @override
  State<PaymentsReportCard> createState() => _PaymentsReportCardState();
}

class _PaymentsReportCardState extends State<PaymentsReportCard> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.05 < 24 ? w * 0.05 : 24),
      decoration: _glassDecoration(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.payment_Report,
              style: AppTextStyles.text17Bold(context)),
          SizedBox(height: w * 0.04),
          _buildSearchField(context),
          SizedBox(height: w * 0.04),
          if (widget.bankController.isLoadingTransactions)
            const Center(child: CircularProgressIndicator())
          else if (widget.bankController.transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text(AppLocalizations.of(context)!.no_Data)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.bankController.transactions.length,
              itemBuilder: (context, index) {
                final item = widget.bankController.transactions[index];
                final isLast =
                    index == widget.bankController.transactions.length - 1;
                return _buildPaymentItemFromApi(w, context, item, isLast);
              },
            ),
          _buildPagination(context),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    final c = widget.bankController;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.bankController.currentPage > 1
                    ? Colors.blueGrey
                    : Colors.grey.shade400,
                foregroundColor: AppColors.text(context),
              ),
              onPressed: widget.bankController.currentPage > 1
                  ? () => widget.bankController.previousPage()
                  : null,
              child: Text(
                AppLocalizations.of(context)!.previous,
                style: AppTextStyles.text15(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "${AppLocalizations.of(context)!.page} ${c.currentPage}",
            style: AppTextStyles.text15(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.bankController.hasNextPage
                    ? Colors.green.withValues(alpha: 0.6)
                    : Colors.grey.shade400,
                foregroundColor: AppColors.text(context),
              ),
              onPressed: widget.bankController.hasNextPage
                  ? () => widget.bankController.nextPage()
                  : null,
              child: Text(
                AppLocalizations.of(context)!.next,
                style: AppTextStyles.text15(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          widget.bankController.getTransactions(page: 1, search: value.trim());
        });
      },
      style: TextStyle(color: AppColors.text(context)),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.search,
        hintStyle:
            TextStyle(color: AppColors.text(context).withValues(alpha: 0.5)),
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
      double w, BuildContext context, TransactionModel item, bool isLast) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isAcceptedStatus(String status) {
      final s = status.trim().toLowerCase();

      return s == "مقبول" || s == "accepted" || s == "approved" || s == "1";
    }

    final isAccepted = isAcceptedStatus(item.status);
    debugPrint("STATUS = ${item.status}");
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: EdgeInsets.all(w * 0.04 < 16 ? w * 0.04 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border:
            Border.all(color: AppColors.text(context).withValues(alpha: 0.15)),
        color: isDark
            ? AppColors.text(context).withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.transType.isNotEmpty ? item.transType : "Transaction",
                    style: AppTextStyles.text17Bold(context),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text("${AppLocalizations.of(context)!.number} ${item.id}",
                    style: AppTextStyles.text13Grey(context),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.timestamp,
                    style: AppTextStyles.text13Grey(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${item.amount} ${AppLocalizations.of(context)!.syp}",
                  style: AppTextStyles.text17Bold(context)),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isAccepted
                      ? Colors.green.withValues(alpha: 0.6)
                      : Colors.orange.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item.status, style: AppTextStyles.text13(context)),
              ),
            ],
          ),
        ],
      ),
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
