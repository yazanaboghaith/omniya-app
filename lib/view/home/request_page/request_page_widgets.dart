import 'dart:async';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';
import 'package:omniya/view/home/request_page/controller/request_page_controller.dart';
import 'package:provider/provider.dart';

Widget buildHeaderTitle(BuildContext context, double h) {
  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Text("تقرير الطلبات", style: AppTextStyles.text19Bold(context)),
  );
}

Widget buildSearchField(
  BuildContext context,
  TextEditingController controller,
  Timer? debounce,
  Function(Timer) setDebounce,
) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: TextField(
      controller: controller,
      onChanged: (value) {
        if (debounce?.isActive ?? false) {
          debounce!.cancel();
        }

        setDebounce(
          Timer(const Duration(milliseconds: 250), () {
            context.read<RequestPageController>().getOrders(
              search: value,
              context: context,
            );
          }),
        );
      },
      style: TextStyle(color: AppColors.text(context)),
      decoration: InputDecoration(
        hintText: "بحث...",
        hintStyle: TextStyle(
          color: AppColors.text(context).withValues(alpha: 1),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.text(context).withValues(alpha: 0.9),
        ),
        filled: true,
        fillColor: AppColors.text(context).withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

Widget buildBody(
  BuildContext context,
  RequestPageController controller,
  List orders,
  Future<void> Function() refresh,
) {
  if (controller.isLoading && controller.data == null) {
    return const Center(child: CircularProgressIndicator());
  }

  if (controller.error != null && controller.data == null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 60, color: Colors.white70),
          const SizedBox(height: 10),
          Text(controller.error ?? "حدث خطأ"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => controller.getOrders(),
            child: const Text("إعادة المحاولة"),
          ),
        ],
      ),
    );
  }

  if (orders.isEmpty) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text("لا توجد بيانات")),
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 60),
    child: Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final item = orders[index];
                final status = item.status.toString().trim();

                return buildRequestCard(
                  context,
                  item.orderType,
                  item.service,
                  item.timestamp,
                  status == "مقبول",
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 15),
        if (controller.isLoadMore)
          const Padding(
            padding: EdgeInsets.all(10),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (controller.hasNextPage || controller.currentPage > 1)
          buildPagination(controller),
      ],
    ),
  );
}

Widget buildPagination(RequestPageController controller) {
  final current = controller.currentPage;

  List<int> pages = [];

  if (current > 1) pages.add(current - 1);
  pages.add(current);
  final nextPage = controller.hasNextPage ? controller.currentPage + 1 : null;
  if (nextPage != null) pages.add(nextPage);
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: pages.map((page) {
      final isActive = page == current;

      return GestureDetector(
        onTap: () {
          if (page != controller.currentPage) {
            controller.getOrders(page: page);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: Text(
            "$page",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }).toList(),
  );
}

Widget buildRequestCard(
  BuildContext context,
  String title,
  String subtitle,
  String date,
  bool isAccepted,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: AppColors.grey(context)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: isAccepted ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(isAccepted ? "مقبول" : "قيد الانتظار"),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Align(alignment: Alignment.centerRight, child: Text(subtitle)),

        const Divider(),

        Row(
          children: [
            const Text("التاريخ:"),
            const SizedBox(width: 5),
            Expanded(child: Text(date)),
          ],
        ),
      ],
    ),
  );
}
