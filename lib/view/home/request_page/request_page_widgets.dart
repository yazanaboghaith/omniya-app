import 'dart:async';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/l10n/app_localizations.dart';
import 'package:omniya/view/home/request_page/controller/request_page_controller.dart';
import 'package:provider/provider.dart';

Widget buildHeaderTitle(BuildContext context, double h) {
  return Padding(
    padding: const EdgeInsets.only(right: 4, bottom: 4),
    child: Text(AppLocalizations.of(context)!.orders_report,
        style: AppTextStyles.text19Bold(context)),
  );
}

Widget buildSearchField(
  BuildContext context,
  TextEditingController controller,
  Timer? debounce,
  Function(Timer) setDebounce,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return TextField(
    controller: controller,
    onChanged: (value) {
      if (debounce?.isActive ?? false) {
        debounce!.cancel();
      }

      setDebounce(
        Timer(const Duration(milliseconds: 250), () {
          context.read<RequestPageController>().getOrders(
                search: value.trim(),
                context: context,
              );
        }),
      );
    },
    style: TextStyle(color: AppColors.text(context)),
    decoration: InputDecoration(
      hintText: AppLocalizations.of(context)!.search,
      hintStyle: TextStyle(
        color: AppColors.text(context).withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: isDark
          ? AppColors.text(context).withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.01),
      prefixIcon: Icon(Icons.search, color: AppColors.text(context)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: AppColors.text(context).withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    ),
  );
}

Widget buildBody(
  BuildContext context,
  RequestPageController controller,
  List orders,
) {
  if (controller.isLoading && controller.data == null) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  if (controller.error != null && controller.data == null) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, size: 50),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => controller.getOrders(),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  if (orders.isEmpty) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: Text(AppLocalizations.of(context)!.no_Data)),
    );
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final item = orders[index];
          final status = item.status.toString().trim();

          return buildRequestCard(
            context,
            item.orderType,
            item.service,
            item.timestamp,
            status,
          );
        },
      ),
      if (controller.isLoadMore)
        const Padding(
          padding: EdgeInsets.all(8),
          child: Center(child: CircularProgressIndicator()),
        ),
    ],
  );
}

Widget buildPagination(
  BuildContext context,
  RequestPageController controller,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.currentPage > 1
                  ? Colors.blueGrey
                  : Colors.grey.shade400,
              foregroundColor: AppColors.text(context),
            ),
            onPressed: controller.currentPage > 1
                ? () {
                    debugPrint(
                        "الضغط على السابق | الصفحة الحالية: ${controller.currentPage}");
                    controller.loadPreviousPage();
                  }
                : null,
            child: Text(
              AppLocalizations.of(context)!.previous,
              style: AppTextStyles.text15(context),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "${AppLocalizations.of(context)!.page} ${controller.currentPage}",
          style: TextStyle(color: AppColors.text(context)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.hasNextPage
                  ? Colors.green.withValues(alpha: 0.6)
                  : Colors.grey.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: controller.hasNextPage
                ? () {
                    debugPrint(
                        "الضغط على التالي | الصفحة الحالية: ${controller.currentPage}");
                    controller.loadNextPage();
                  }
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

Widget buildRequestCard(
  BuildContext context,
  String title,
  String subtitle,
  String date,
  String status,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: AppColors.text(context).withValues(alpha: 0.15),
      ),
      color: isDark
          ? AppColors.text(context).withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.03),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty
                        ? title
                        : AppLocalizations.of(context)!.order,
                    style: AppTextStyles.text17Bold(context),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    subtitle,
                    style: AppTextStyles.text15(context),
                  ),
                ],
              ),
            ),
            SizedBox(width: width * 0.01),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status == AppLocalizations.of(context)!.accepted
                      ? Colors.green.withValues(alpha: 0.6)
                      : status == AppLocalizations.of(context)!.rejected
                          ? Colors.red.withValues(alpha: 0.6)
                          : Colors.orange.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.text13(context),
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            height: 1,
            thickness: 1,
            endIndent: 5,
            indent: 5,
          ),
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.date,
                style: AppTextStyles.text13Grey(context)),
            Expanded(
              child: Text(
                date,
                style: AppTextStyles.text13Grey(context),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
