import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omniya/const/url.dart';
import 'package:omniya/model/orders_response.dart';
import 'package:omniya/view/auth/services/api_client.dart';

// 1. إضافة حالة unauthorized للتعامل مع انتهاء الجلسة
enum RequestState {
  idle,
  loading,
  success,
  noInternet,
  serverError,
  error,
  unauthorized,
}

class RequestPageController with ChangeNotifier {
  // 2. تعريف نسخة واحدة من ApiClient للحفاظ على Lock التجديد
  final ApiClient apiClient = ApiClient();

  bool isLoading = false;
  String? error;

  RequestState state = RequestState.idle;

  OrdersResponseModel? data;

  List<OrderModel> orders = [];

  int currentPage = 1;

  bool hasNextPage = true;

  bool isLoadMore = false;

  final String apiorders = "${AppApi.Url}${AppApi.apiorders}";

  Future<void> getOrders({
    int page = 1,
    String? search,
    bool loadMore = false,
    BuildContext? context,
  }) async {
    if (loadMore && isLoadMore) return;
    if (!loadMore && isLoading) return;

    if (loadMore) {
      isLoadMore = true;
    } else {
      isLoading = true;
      state = RequestState.loading;
    }

    error = null;
    notifyListeners();

    try {
      // String url = "$apiorders?page=$page&page_size=10";
      String url = "$apiorders";

      if (search != null && search.trim().isNotEmpty) {
        // url += "&search=${Uri.encodeComponent(search)}";
        url += "?search=${Uri.encodeComponent(search)}";
      }

      debugPrint("API REQUEST URL: $url");

      // 3. استخدام النسخة الموحدة بدلاً من ApiClient().get(...)
      final response = await apiClient.get(Uri.parse(url));

      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        data = OrdersResponseModel.fromJson(jsonData);

        if (page == 1) {
          orders.clear();
        }

        final newItems = data?.results ?? [];

        orders.addAll(
          newItems.where(
            (item) => !orders.any(
              (e) => e.timestamp == item.timestamp && e.service == item.service,
            ),
          ),
        );
        currentPage = page;
        hasNextPage = data?.next != null; // مبسطة بناءً على كودك الأصلي
        state = RequestState.success;
      } else {
        // تم مسح فحص 401 من هنا لأنه لن يحدث، الـ ApiClient يعالجه!
        error = "فشل في جلب البيانات";
        state = RequestState.serverError;
      }
    } catch (e) {
      // 4. التقاط استثناء انتهاء الجلسة هنا
      if (e.toString().contains("SESSION_EXPIRED")) {
        final msg = "انتهت الجلسة، يجب إعادة تسجيل الدخول";
        error = msg;
        state = RequestState.unauthorized; // تغيير الحالة

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        error = e.toString();
        state = RequestState.error;
      }
    }

    isLoading = false;
    isLoadMore = false;

    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (!hasNextPage || isLoadMore) return;

    final nextPage = currentPage + 1;
    await getOrders(page: nextPage, loadMore: true);
  }

  Future<void> refreshOrders() async {
    currentPage = 1;
    hasNextPage = true;
    orders.clear();

    await getOrders(page: 1);
  }
}
