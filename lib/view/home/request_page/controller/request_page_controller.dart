import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/model/orders_response.dart';
import 'package:omniya/core/services/api_client.dart';
import 'package:omniya/core/services/api_error_handler.dart';

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
  final ApiClient apiClient = ApiClient();

  bool isLoading = false;
  String? error;

  RequestState state = RequestState.idle;

  OrdersResponseModel? data;

  List<OrderModel> orders = [];

  int currentPage = 1;

  bool hasNextPage = true;

  bool isLoadMore = false;

  final String apiorders = "${AppApi.url}${AppApi.apiorders}";

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
      String url = "$apiorders?page=$page&page_size=10";

      if (search != null && search.trim().isNotEmpty) {
        url += "&search=${Uri.encodeComponent(search)}";
      }

      final response = await apiClient.get(
        Uri.parse(url),
      );
      debugPrint(
        "ORDERS STATUS CODE => ${response.statusCode}",
      );
      debugPrint(
        "ORDERS RESPONSE BODY => ${response.body}",
      );
      Map<String, dynamic>? responseData;

      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          "Response is not valid JSON => $e",
        );
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        data = OrdersResponseModel.fromJson(jsonData);
        final newItems = data?.results ?? [];
        if (!loadMore) {
          orders = newItems;
        } else {
          orders.addAll(
            newItems.where(
              (item) => !orders.any(
                (e) =>
                    e.timestamp == item.timestamp && e.service == item.service,
              ),
            ),
          );
        }

        currentPage = page;
        hasNextPage = data?.next != null;

        state = RequestState.success;
      } else if (response.statusCode == 401) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          error = serverMessage;
        } else if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        state = RequestState.unauthorized;

        debugPrint(
          "401 SERVER ERROR MESSAGE => $error",
        );
      } else if (response.statusCode == 406) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          error = serverMessage;
        } else if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        state = RequestState.serverError;

        debugPrint(
          "406 SERVER ERROR MESSAGE => $error",
        );
      } else if (response.statusCode == 429) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          error = serverMessage;
        } else if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        state = RequestState.serverError;

        debugPrint(
          "429 SERVER ERROR MESSAGE => $error",
        );
      }

      // ============================================================
      // Other Server Errors
      // ============================================================

      else {
        if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        state = RequestState.serverError;

        debugPrint(
          "UNHANDLED SERVER ERROR => ${response.statusCode}",
        );

        debugPrint(
          "ERROR MESSAGE => $error",
        );
      }
    } catch (e) {
      debugPrint(
        "GET ORDERS ERROR => $e",
      );

      error = e.toString();

      state = RequestState.error;
    }

    isLoading = false;
    isLoadMore = false;

    notifyListeners();
  }

  Future<void> loadPreviousPage() async {
    if (currentPage <= 1) return;

    final prevPage = currentPage - 1;

    await getOrders(
      page: prevPage,
      loadMore: false,
    );
  }

  Future<void> loadNextPage() async {
    if (!hasNextPage || isLoadMore) return;

    final nextPage = currentPage + 1;

    await getOrders(
      page: nextPage,
      loadMore: true,
    );
  }

  Future<void> refreshOrders() async {
    currentPage = 1;
    hasNextPage = true;
    orders.clear();

    await getOrders(
      page: 1,
    );
  }
}
