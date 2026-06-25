import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/model/bank_model.dart';
import 'package:omniya/model/transactions_model.dart';
import 'package:omniya/core/services/api_client.dart';

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

  Future<void> getBanks() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await apiClient.get(Uri.parse(apifinancebanks));
      final data = jsonDecode(response.body);

      debugPrint(" BANK RESPONSE CODE: ${response.statusCode}");

      if (response.statusCode == 200) {
        final result = BankResponse.fromJson(data);
        banks = result.data;
      } else {
        error = data["message"] ?? "فشل في جلب البيانات";
      }
    } catch (e) {
      if (e.toString().contains("SESSION_EXPIRED")) {
        error = "انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.";
      } else {
        error = "حدث خطأ في الاتصال";
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addBankPayment({
    required int bankId,
    required String amount,
    required String bankRefNo,
    BuildContext? context,
  }) async {
    isSendingPayment = true;
    notifyListeners();

    final Map<String, dynamic> payload = {
      "bank_id": bankId,
      "amount": amount,
      "bank_ref_no": bankRefNo,
    };

    try {
      debugPrint("--- إرسال دفعة جديدة ---");
      debugPrint("URL: $apiaddbankPayment");
      debugPrint("DATA: $payload");

      final response = await apiClient.post(
        Uri.parse(apiaddbankPayment),
        payload,
      );

      debugPrint("RESPONSE CODE: ${response.statusCode}");
      debugPrint("RESPONSE BODY: ${response.body}");
      debugPrint("-----------------------");

      // final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // final message = data["message"] ?? "تم إرسال الدفعة بنجاح";

        // if (context != null && context.mounted) {
        //   AppNotifier.instance.success(context, message,);
        // }
        return true;
      } else {
        // final errorMessage =
        //     data["message"] ?? data["error"] ?? "فشل في إرسال الدفعة";
        // if (context != null && context.mounted) {
        //   AppNotifier.instance.error(context, errorMessage);
        // }
        return false;
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      if (context != null && context.mounted) {
        // final isSessionExpired = e.toString().contains("SESSION_EXPIRED");
        // final msg = isSessionExpired
        //     ? "انتهت جلستك، يرجى تسجيل الدخول"
        //     : "حدث خطأ أثناء الاتصال";

        // AppNotifier.instance.error(context, msg);
      }
      return false;
    } finally {
      isSendingPayment = false;
      notifyListeners();
    }
  }

  Future<void> searchTransactions({
    required String query,
    BuildContext? context,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(
        apitransactions,
      ).replace(queryParameters: {"search": query});

      final response = await apiClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data["results"];
        if (results != null) {
          debugPrint(" DATA FOUND: ${results.length} items");
        }
      }
    } catch (e) {
      if (e.toString().contains("SESSION_EXPIRED")) {
        debugPrint("Session Expired during search!");
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> getTransactions({
    required int page,
    String? search,
  }) async {
    if (isLoadingTransactions) return;

    isLoadingTransactions = true;
    notifyListeners();

    try {
      currentPage = page;
      final Map<String, String> queryParams = {};
      if (page > 1) {
        queryParams["page"] = page.toString();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams["search"] = search.trim();
      }
      final uri =
          Uri.parse(apitransactions).replace(queryParameters: queryParams);
      debugPrint(" Request URL => $uri");

      final response = await apiClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final res = TransactionResponse.fromJson(data);

        transactions = res.results;

        nextPageUrl = res.next;
        prevPageUrl = res.previous;
      } else {
        debugPrint(" SERVER ERROR => Status Code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(" CATCH ERROR => $e");
    }

    isLoadingTransactions = false;
    notifyListeners();
  }
////////////////////
////////////////////
//////////////////
////////////////////

  Future<void> loadMoreTransactions() async {
    if (nextPageUrl == null || isLoadingMore) return;
    isLoadingMore = true;
    notifyListeners();

    try {
      final response = await apiClient.get(Uri.parse(nextPageUrl!));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final res = TransactionResponse.fromJson(data);
        transactions = res.results;
        nextPageUrl = res.next;
      }
    } catch (e) {
      debugPrint("LOAD MORE ERROR => $e");
    }

    isLoadingMore = false;
    notifyListeners();
  }

//////////////////
////////////////////
///////////////////
/////////////////
  bool get hasNextPage => nextPageUrl != null;
  bool get hasPreviousPage => prevPageUrl != null;

  Future<void> nextPage() async {
    if (!hasNextPage) return;

    currentPage++;
    notifyListeners();

    debugPrint(" NEXT PAGE: $currentPage");
    await getTransactions(page: currentPage, search: currentSearch);
  }

  Future<void> previousPage() async {
    if (currentPage <= 1) return;

    currentPage--;
    notifyListeners();

    debugPrint(" PREVIOUS PAGE: $currentPage");
    await getTransactions(page: currentPage, search: currentSearch);
  }
}
