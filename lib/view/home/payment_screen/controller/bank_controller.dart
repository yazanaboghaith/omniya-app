import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/model/payment_methods_response.dart';
import 'package:omniya/model/payment_response.dart';
import 'package:omniya/core/services/api_client.dart';
import 'package:omniya/core/services/api_error_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentSession {
  int? transactionId;
  String? paymentUrl;
  String? paymentType;

  bool isActive = false;
  bool wentToBrowser = false;

  void clear() {
    transactionId = null;
    paymentUrl = null;
    paymentType = null;
    isActive = false;
    wentToBrowser = false;
  }
}

class Bankcontroller with ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  final String apiepaymentactivemethods =
      "${AppApi.url}${AppApi.epaymentactivemethods}";

  final String apiepaymentcreatepayment =
      "${AppApi.url}${AppApi.epaymentcreatepayment}";

  final String apiepaymentcheckpayment =
      "${AppApi.url}${AppApi.epaymentcheckpayment}";

  bool isLoading = false;
  String? error;

  List<PaymentMethod> methods = [];

  final PaymentSession session = PaymentSession();

  // =========================================================
  // GET PAYMENT METHODS
  // =========================================================

  Future<void> getPaymentMethods({
    BuildContext? context,
  }) async {
    debugPrint(
      " [PAYMENT METHODS] Loading...",
    );

    isLoading = true;
    error = null;

    notifyListeners();

    try {
      final response = await apiClient.get(
        Uri.parse(apiepaymentactivemethods),
      );

      debugPrint(
        " STATUS => ${response.statusCode}",
      );

      debugPrint(
        " BODY => ${response.body}",
      );

      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          " JSON PARSE ERROR => $e",
        );
      }

      // =========================================================
      // 200 - SUCCESS
      // =========================================================

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final result = PaymentMethodsResponse.fromJson(data);

        methods = result.data;

        debugPrint(
          " METHODS LOADED => ${methods.length}",
        );
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
          " SERVER ERROR => $error",
        );
      }

      // =========================================================
      // OTHER SERVER ERRORS
      // =========================================================

      else {
        if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = "Server Error";
        }

        debugPrint(
          " UNHANDLED ERROR => ${response.statusCode}",
        );

        debugPrint(
          " ERROR => $error",
        );
      }
    } catch (e) {
      error = e.toString();

      debugPrint(
        " EXCEPTION => $e",
      );
    }

    isLoading = false;

    notifyListeners();
  }

  // =========================================================
  // CREATE PAYMENT
  // =========================================================

  Future<bool> createPayment({
    required String amount,
    required String paymentType,
    BuildContext? context,
  }) async {
    debugPrint(
      " CREATE PAYMENT START",
    );

    debugPrint(
      " Amount => $amount",
    );

    debugPrint(
      " Payment Type => $paymentType",
    );

    isLoading = true;
    error = null;

    notifyListeners();

    final body = {
      "amount": amount,
      "payment_type": paymentType,
    };

    debugPrint(
      " REQUEST => $apiepaymentcreatepayment",
    );

    debugPrint(
      " BODY => $body",
    );

    try {
      final response = await apiClient.post(
        Uri.parse(apiepaymentcreatepayment),
        body,
      );

      debugPrint(
        " STATUS => ${response.statusCode}",
      );

      debugPrint(
        " RESPONSE => ${response.body}",
      );

      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          " JSON PARSE ERROR => $e",
        );
      }

      // =========================================================
      // 200 - SUCCESS
      // =========================================================

      if (response.statusCode == 200 && responseData?["success"] == true) {
        final paymentData = responseData!["data"];

        session.transactionId = paymentData["transaction_id"];

        session.paymentUrl = paymentData["url"];

        session.paymentType = paymentType;

        session.isActive = true;

        debugPrint(
          " PAYMENT CREATED SUCCESS",
        );

        debugPrint(
          " Transaction ID => ${session.transactionId}",
        );

        debugPrint(
          " Payment URL => ${session.paymentUrl}",
        );

        return true;
      }


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

      // =========================================================
      // OTHER SERVER ERRORS
      // =========================================================

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

        debugPrint(
          " ERROR => $error",
        );

        return false;
      }
    } catch (e) {
      error = e.toString();

      debugPrint(
        " EXCEPTION => $e",
      );

      return false;
    } finally {
      isLoading = false;

      notifyListeners();

      debugPrint(
        " CREATE PAYMENT END",
      );
    }
  }

  // =========================================================
  // OPEN PAYMENT URL
  // =========================================================

  Future<void> openPaymentUrl() async {
    if (session.paymentUrl == null) {
      debugPrint(
        " No payment URL found",
      );

      return;
    }

    final uri = Uri.parse(
      session.paymentUrl!,
    );

    debugPrint(
      " URL => $uri",
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  // =========================================================
  // CHECK PAYMENT
  // =========================================================

  Future<bool> checkPayment({
    BuildContext? context,
  }) async {
    debugPrint(
      " CHECK PAYMENT START",
    );

    if (session.transactionId == null) {
      debugPrint(
        "No transaction ID",
      );

      return false;
    }

    final url = "${AppApi.url}"
        "${AppApi.epaymentcheckpayment}"
        "/${session.transactionId}";

    debugPrint(
      " CHECK URL => $url",
    );

    try {
      final response = await apiClient.get(
        Uri.parse(url),
      );

      debugPrint(
        " STATUS => ${response.statusCode}",
      );

      debugPrint(
        " BODY => ${response.body}",
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
          " JSON PARSE ERROR => $e",
        );
      }

      // =========================================================
      // 200 - SUCCESS
      // =========================================================

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        final result = PaymentResponse.fromJson(data);

        if (result.success == true) {
          debugPrint(
            " PAYMENT SUCCESS => ${result.data}",
          );

          error = null;

          return result.data;
        }

        error = result.message;

        debugPrint(
          " PAYMENT FAILED => ${result.message}",
        );

        return false;
      }

      // =========================================================
      // 401 / 406 / 429
      // =========================================================

      else if (response.statusCode == 401 ||
          response.statusCode == 406 ||
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

      // =========================================================
      // OTHER SERVER ERRORS
      // =========================================================

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
      error = e.toString();

      debugPrint(
        " EXCEPTION => $e",
      );

      return false;
    } finally {
      isLoading = false;

      notifyListeners();

      debugPrint(
        " CHECK PAYMENT END",
      );
    }
  }
}
