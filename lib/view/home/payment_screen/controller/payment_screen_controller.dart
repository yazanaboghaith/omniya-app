import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/model/bank_model.dart';
import 'package:omniya/model/transactions_model.dart';
import 'package:omniya/core/services/api_client.dart';
import 'package:omniya/core/services/api_error_handler.dart';

class PaymentBankController with ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  bool isLoading = false;
  String? error;

  bool isSendingPayment = false;

  List<BankModel> banks = [];

  List<TransactionModel> transactions = [];

  bool isLoadingTransactions = false;

  bool isLoadingMore = false;

  int currentPage = 1;

  String? nextPageUrl;
  String? prevPageUrl;
  String? previousPageUrl;
  String? currentSearch;

  final String apifinancebanks = "${AppApi.url}${AppApi.financebanks}";

  final String apiaddbankPayment = "${AppApi.url}${AppApi.addbankPayment}";

  final String apitransactions = "${AppApi.url}${AppApi.apitransactions}";

  // ============================================================
  // GET BANKS
  // ============================================================

  Future<void> getBanks({
    BuildContext? context,
  }) async {
    isLoading = true;
    error = null;

    notifyListeners();

    try {
      final response = await apiClient.get(
        Uri.parse(apifinancebanks),
      );

      debugPrint(
        " BANK RESPONSE CODE: ${response.statusCode}",
      );

      debugPrint(
        " BANK RESPONSE BODY: ${response.body}",
      );

      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          " BANK JSON PARSE ERROR => $e",
        );
      }

      // ==========================================================
      // 200 - SUCCESS
      // ==========================================================

      if (response.statusCode == 200) {
        final result = BankResponse.fromJson(
          responseData ?? {},
        );

        banks = result.data;
      } else if (response.statusCode == 401 ||
          response.statusCode == 406 ||
          response.statusCode == 403 ||
          response.statusCode == 429) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        } else if (responseData?["msg"] != null) {
          serverMessage = responseData!["msg"].toString();
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

        debugPrint(
          " BANK SERVER ERROR => $error",
        );
      }

      // ==========================================================
      // OTHER HTTP ERRORS
      // ==========================================================

      else {
        if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        debugPrint(
          " BANK UNHANDLED ERROR => "
          "${response.statusCode}",
        );

        debugPrint(
          " BANK ERROR => $error",
        );
      }
    } catch (e) {
      debugPrint(
        "BANK ERROR: $e",
      );

      if (e.toString().contains("SESSION_EXPIRED")) {
        error = "انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.";
      } else if (context != null) {
        error = ApiErrorHandler.getUnhandledErrorMessage(
          context: context,
        );
      } else {
        error = "Server Error";
      }
    }

    isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // ADD BANK PAYMENT
  // ============================================================

  Future<bool> addBankPayment({
    required int bankId,
    required String amount,
    required String bankRefNo,
    BuildContext? context,
  }) async {
    isSendingPayment = true;
    error = null;

    notifyListeners();

    final Map<String, dynamic> payload = {
      "bank_id": bankId,
      "amount": amount,
      "bank_ref_no": bankRefNo,
    };

    try {
      debugPrint(
        "--- إرسال دفعة جديدة ---",
      );

      debugPrint(
        "URL: $apiaddbankPayment",
      );

      debugPrint(
        "DATA: $payload",
      );

      final response = await apiClient.post(
        Uri.parse(apiaddbankPayment),
        payload,
      );

      debugPrint(
        "RESPONSE CODE: ${response.statusCode}",
      );

      debugPrint(
        "RESPONSE BODY: ${response.body}",
      );

      debugPrint(
        "-----------------------",
      );

      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(
          response.body,
        );

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          " PAYMENT JSON PARSE ERROR => $e",
        );
      }

      // ==========================================================
      // 200 / 201 - SUCCESS
      // ==========================================================

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      // ==========================================================
      // 401 / 406 / 429
      // ==========================================================

      else if (response.statusCode == 401 ||
          response.statusCode == 406 ||
          response.statusCode == 403 ||
          response.statusCode == 429) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        } else if (responseData?["msg"] != null) {
          serverMessage = responseData!["msg"].toString();
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

        debugPrint(
          " PAYMENT SERVER ERROR => $error",
        );

        return false;
      }

      // ==========================================================
      // OTHER HTTP ERRORS
      // ==========================================================

      else {
        if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        debugPrint(
          " PAYMENT UNHANDLED ERROR => "
          "${response.statusCode}",
        );

        return false;
      }
    } catch (e) {
      debugPrint(
        "ERROR: $e",
      );

      if (e.toString().contains("SESSION_EXPIRED")) {
        error = "انتهت جلستك، يرجى تسجيل الدخول";
      } else if (context != null) {
        error = ApiErrorHandler.getUnhandledErrorMessage(
          context: context,
        );
      } else {
        error = "Server Error";
      }

      return false;
    } finally {
      isSendingPayment = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SEARCH TRANSACTIONS
  // ============================================================

  Future<void> searchTransactions({
    required String query,
    BuildContext? context,
  }) async {
    isLoading = true;
    error = null;

    notifyListeners();

    try {
      final uri = Uri.parse(
        apitransactions,
      ).replace(
        queryParameters: {
          "search": query,
        },
      );

      final response = await apiClient.get(uri);

      debugPrint(
        " SEARCH STATUS => ${response.statusCode}",
      );

      debugPrint(
        " SEARCH BODY => ${response.body}",
      );

      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(
          response.body,
        );

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          " SEARCH JSON PARSE ERROR => $e",
        );
      }

      // ==========================================================
      // 200 - SUCCESS
      // ==========================================================

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        final results = data["results"];

        if (results != null) {
          debugPrint(
            " DATA FOUND: ${results.length} items",
          );
        }
      } else if (response.statusCode == 401 ||
          response.statusCode == 406 ||
          response.statusCode == 403 ||
          response.statusCode == 429) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        } else if (responseData?["msg"] != null) {
          serverMessage = responseData!["msg"].toString();
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

        debugPrint(
          " SEARCH SERVER ERROR => $error",
        );
      }

      // ==========================================================
      // OTHER HTTP ERRORS
      // ==========================================================

      else {
        if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        debugPrint(
          " SEARCH UNHANDLED ERROR => "
          "${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(
        "SEARCH ERROR => $e",
      );

      if (e.toString().contains("SESSION_EXPIRED")) {
        error = "انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.";
      } else if (context != null) {
        error = ApiErrorHandler.getUnhandledErrorMessage(
          context: context,
        );
      } else {
        error = "Server Error";
      }
    }

    isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // GET TRANSACTIONS
  // ============================================================

  Future<void> getTransactions({
    required int page,
    String? search,
    BuildContext? context,
  }) async {
    if (isLoadingTransactions) return;

    isLoadingTransactions = true;
    error = null;

    notifyListeners();

    try {
      currentPage = page;
      currentSearch = search;

      final Map<String, String> queryParams = {};

      if (page > 1) {
        queryParams["page"] = page.toString();
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams["search"] = search.trim();
      }

      final uri = Uri.parse(
        apitransactions,
      ).replace(
        queryParameters: queryParams,
      );

      debugPrint(
        " Request URL => $uri",
      );

      final response = await apiClient.get(uri);

      debugPrint(
        " TRANSACTIONS STATUS => "
        "${response.statusCode}",
      );

      debugPrint(
        " TRANSACTIONS BODY => "
        "${response.body}",
      );

      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(
          response.body,
        );

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          " TRANSACTIONS JSON PARSE ERROR => $e",
        );
      }

      // ==========================================================
      // 200 - SUCCESS
      // ==========================================================

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        final res = TransactionResponse.fromJson(data);

        transactions = res.results;

        nextPageUrl = res.next;

        prevPageUrl = res.previous;
      } else if (response.statusCode == 401 ||
          response.statusCode == 406 ||
          response.statusCode == 403 ||
          response.statusCode == 429) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        } else if (responseData?["msg"] != null) {
          serverMessage = responseData!["msg"].toString();
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

        debugPrint(
          " TRANSACTIONS SERVER ERROR => $error",
        );
      }

      // ==========================================================
      // OTHER HTTP ERRORS
      // ==========================================================

      else {
        if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        debugPrint(
          " TRANSACTIONS UNHANDLED ERROR => "
          "${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(
        " CATCH ERROR => $e",
      );

      if (e.toString().contains("SESSION_EXPIRED")) {
        error = "انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.";
      } else if (context != null) {
        error = ApiErrorHandler.getUnhandledErrorMessage(
          context: context,
        );
      } else {
        error = "Server Error";
      }
    }

    isLoadingTransactions = false;

    notifyListeners();
  }

  // ============================================================
  // LOAD MORE TRANSACTIONS
  // ============================================================

  Future<void> loadMoreTransactions({
    BuildContext? context,
  }) async {
    if (nextPageUrl == null || isLoadingMore) {
      return;
    }

    isLoadingMore = true;
    error = null;

    notifyListeners();

    try {
      final response = await apiClient.get(
        Uri.parse(nextPageUrl!),
      );

      debugPrint(
        " LOAD MORE STATUS => "
        "${response.statusCode}",
      );

      debugPrint(
        " LOAD MORE BODY => "
        "${response.body}",
      );

      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(
          response.body,
        );

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          " LOAD MORE JSON PARSE ERROR => $e",
        );
      }

      // ==========================================================
      // 200 - SUCCESS
      // ==========================================================

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        final res = TransactionResponse.fromJson(data);

        transactions = res.results;

        nextPageUrl = res.next;
      } else if (response.statusCode == 401 ||
          response.statusCode == 406 ||
          response.statusCode == 403 ||
          response.statusCode == 429) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        } else if (responseData?["msg"] != null) {
          serverMessage = responseData!["msg"].toString();
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

        debugPrint(
          " LOAD MORE SERVER ERROR => $error",
        );
      }

      // ==========================================================
      // OTHER HTTP ERRORS
      // ==========================================================

      else {
        if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        debugPrint(
          " LOAD MORE UNHANDLED ERROR => "
          "${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(
        "LOAD MORE ERROR => $e",
      );

      if (e.toString().contains("SESSION_EXPIRED")) {
        error = "انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.";
      } else if (context != null) {
        error = ApiErrorHandler.getUnhandledErrorMessage(
          context: context,
        );
      } else {
        error = "Server Error";
      }
    }

    isLoadingMore = false;

    notifyListeners();
  }

  bool get hasNextPage => nextPageUrl != null;

  bool get hasPreviousPage => prevPageUrl != null;

  Future<void> nextPage({
    BuildContext? context,
  }) async {
    if (!hasNextPage) return;

    currentPage++;

    notifyListeners();

    debugPrint(
      " NEXT PAGE: $currentPage",
    );

    await getTransactions(
      page: currentPage,
      search: currentSearch,
      context: context,
    );
  }

  Future<void> previousPage({
    BuildContext? context,
  }) async {
    if (currentPage <= 1) return;

    currentPage--;

    notifyListeners();

    debugPrint(
      " PREVIOUS PAGE: $currentPage",
    );

    await getTransactions(
      page: currentPage,
      search: currentSearch,
      context: context,
    );
  }
}
