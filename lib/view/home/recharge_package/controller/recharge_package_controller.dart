import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_notifier.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/model/data_model.dart';
import 'package:omniya/core/services/api_client.dart';

enum PackageState { idle, loading, success, serverError, error, unauthorized }

class RechargePackageController with ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  bool isLoading = false;
  String? error;
  bool isSubmitting = false;
  PackageState state = PackageState.idle;
  DataModel? data;

  final String apiallpackages = "${AppApi.url}${AppApi.allpackages}";
  final String apiPackagesChargeExtraPackage =
      "${AppApi.url}${AppApi.packageschargeextrapackage}";

  Future<void> getallpackage({
    BuildContext? context,
    bool refresh = false,
  }) async {
    debugPrint(" [Packages] START request");

    isLoading = true;
    state = PackageState.loading;
    error = null;
    notifyListeners();

    try {
      debugPrint(" URL: $apiallpackages");

      final response = await apiClient.get(Uri.parse(apiallpackages));

      debugPrint("STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        data = DataModel.fromJson(jsonData);

        debugPrint(" DATA PARSED SUCCESSFULLY");
        state = PackageState.success;
      } else {
        error = "Server error: ${response.statusCode}";
        state = PackageState.serverError;
      }
    } catch (e) {
      if (e.toString().contains("SESSION_EXPIRED")) {
        error = "Unauthorized - يرجى تسجيل الدخول مرة أخرى";
        state = PackageState.unauthorized;

        if (context != null && context.mounted) {
          AppNotifier.instance.error(context, " يرجى تسجيل الدخول مرة أخرى");
        }
      } else {
        error = e.toString();
        state = PackageState.error;
      }
    }

    isLoading = false;
    notifyListeners();

    debugPrint(" [Packages] END request");
  }

//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////

  Future<String> chargeExtraPackage({
    required int addonId,
    required bool isPostPaid,
  }) async {
    debugPrint("[CHARGE PACKAGE] START");

    isLoading = true;
    state = PackageState.loading;
    notifyListeners();

    String serverMessage = "حدث خطأ غير متوقع";

    try {
      final url = Uri.parse(apiPackagesChargeExtraPackage);

      debugPrint("REQUEST URL: $url");

      final Map<String, dynamic> body = {
        "addon_id": addonId,
      };
      if (isPostPaid) {
        body["post_paid"] = "1";
      }
      debugPrint("REQUEST BODY => $body");

      final response = await apiClient.post(url, body);

      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("RESPONSE BODY: ${response.body}");

      try {
        final data = jsonDecode(response.body);

        if (data is Map) {
          final rawMessage = data["message"] ?? data["error"] ?? data["msg"];

          if (rawMessage != null) {
            serverMessage = rawMessage.toString();
          }
        }
      } catch (e) {
        debugPrint("JSON PARSE ERROR: $e");

        serverMessage = response.body.isNotEmpty
            ? response.body
            : "خطأ في الاتصال بالسيرفر";
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = PackageState.success;
        debugPrint("STATE: SUCCESS");
      } else {
        state = PackageState.serverError;
        debugPrint("STATE: SERVER ERROR");
      }
    } catch (e) {
      debugPrint("EXCEPTION: $e");

      if (e.toString().contains("SESSION_EXPIRED")) {
        state = PackageState.unauthorized;
        serverMessage = "انتهت الجلسة، يرجى تسجيل الدخول مجدداً";
      } else {
        state = PackageState.error;
        serverMessage = "تأكد من اتصالك بالإنترنت وحاول مجدداً";
      }
    }

    isLoading = false;
    notifyListeners();

    debugPrint("[CHARGE PACKAGE] END");

    return serverMessage;
  }
}
