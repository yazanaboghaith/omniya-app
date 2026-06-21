import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omniya/const/url.dart';
import 'package:omniya/model/payment_methods_response.dart';
import 'package:omniya/model/payment_response.dart';
import 'package:omniya/view/auth/services/api_client.dart';
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
  Future<void> getPaymentMethods() async {
    debugPrint(" [PAYMENT METHODS] Loading...");

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await apiClient.get(
        Uri.parse(apiepaymentactivemethods),
      );
      debugPrint(" STATUS => ${response.statusCode}");
      debugPrint(" BODY => ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final result = PaymentMethodsResponse.fromJson(data);
        methods = result.data;

        debugPrint(" METHODS LOADED => ${methods.length}");
      } else {
        error = data["message"]?.toString() ?? "Failed to load methods";
        debugPrint(" ERROR => $error");
      }
    } catch (e) {
      error = "Exception: $e";
      debugPrint(" EXCEPTION => $e");
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
  }) async {
    debugPrint(" CREATE PAYMENT START");
    debugPrint(" Amount => $amount");
    debugPrint(" Payment Type => $paymentType");

    isLoading = true;
    error = null;
    notifyListeners();

    final body = {
      "amount": amount,
      "payment_type": paymentType,
    };

    debugPrint(" REQUEST => $apiepaymentcreatepayment");
    debugPrint(" BODY => $body");

    try {
      final response = await apiClient.post(
        Uri.parse(apiepaymentcreatepayment),
        body,
      );

      debugPrint(" STATUS => ${response.statusCode}");
      debugPrint(" RESPONSE => ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final paymentData = data["data"];

        session.transactionId = paymentData["transaction_id"];
        session.paymentUrl = paymentData["url"];
        session.paymentType = paymentType;
        session.isActive = true;

        debugPrint(" PAYMENT CREATED SUCCESS");
        debugPrint(" Transaction ID => ${session.transactionId}");
        debugPrint(" Payment URL => ${session.paymentUrl}");

        return true;
      } else {
        error = data["message"]?.toString() ?? "Payment failed";
        debugPrint(" PAYMENT FAILED => $error");
        return false;
      }
    } catch (e) {
      error = "Exception: $e";
      debugPrint(" EXCEPTION => $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      debugPrint(" CREATE PAYMENT END");
    }
  }

  // =========================================================
  // OPEN PAYMENT URL
  // =========================================================
  Future<void> openPaymentUrl() async {
    if (session.paymentUrl == null) {
      debugPrint(" No payment URL found");
      return;
    }

    final uri = Uri.parse(session.paymentUrl!);

    debugPrint(" URL => $uri");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // =========================================================
  // CHECK PAYMENT
  // =========================================================
  Future<bool> checkPayment() async {
    debugPrint(" CHECK PAYMENT START");

    if (session.transactionId == null) {
      debugPrint("No transaction ID");
      return false;
    }

    final url =
        "${AppApi.url}${AppApi.epaymentcheckpayment}/${session.transactionId}";

    debugPrint(" CHECK URL => $url");

    try {
      final response = await apiClient.get(Uri.parse(url));

      debugPrint(" STATUS => ${response.statusCode}");
      debugPrint(" BODY => ${response.body}");

      final data = jsonDecode(response.body);
      final result = PaymentResponse.fromJson(data);

      if (response.statusCode == 200 && result.success == true) {
        debugPrint(" PAYMENT SUCCESS => ${result.data}");
        return result.data;
      } else {
        error = result.message;
        debugPrint(" PAYMENT FAILED => ${result.message}");
        return false;
      }
    } catch (e) {
      error = "Exception: $e";
      debugPrint(" EXCEPTION => $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      debugPrint(" CHECK PAYMENT END");
    }
  }
}
