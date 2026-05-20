import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omniya/const/url.dart';
import 'package:omniya/model/data_model.dart';
import 'package:omniya/view/auth/services/api_client.dart';

enum PackageState { idle, loading, success, serverError, error, unauthorized }

class RechargePackageController with ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  bool isLoading = false;
  String? error;
  bool isSubmitting = false;
  PackageState state = PackageState.idle;
  DataModel? data;

  final String apiallpackages = "${AppApi.Url}${AppApi.allpackages}";
  final String apiPackagesChargeExtraPackage =
      "${AppApi.Url}${AppApi.packageschargeextrapackage}";

  Future<void> getallpackage({
    BuildContext? context,
    bool refresh = false,
  }) async {
    debugPrint(" [Packages] START request");
    if (!refresh) {
      isLoading = true;
      notifyListeners();
    }
    isLoading = true;
    state = PackageState.loading;
    error = null;
    notifyListeners();

    try {
      debugPrint("📡 URL: $apiallpackages");

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
        debugPrint(" SERVER ERROR: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("SESSION_EXPIRED")) {
        error = "Unauthorized - يرجى تسجيل الدخول مرة أخرى";
        state = PackageState.unauthorized;

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("انتهت الجلسة، يجب إعادة تسجيل الدخول"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        error = e.toString();
        state = PackageState.error;
      }
      debugPrint(" EXCEPTION OCCURRED: $error");
    }

    isLoading = false;
    notifyListeners();
    debugPrint(" [Packages] END request");
  }

  Future<String> chargeExtraPackage({
    required int addonId,
    required String postPaid,
  }) async {
    debugPrint("[CHARGE PACKAGE] START");

    isLoading = true;
    state = PackageState.loading;
    notifyListeners();

    String serverMessage = "حدث خطأ غير متوقع";

    try {
      final url = Uri.parse(apiPackagesChargeExtraPackage);
      final body = {"addon_id": addonId, "post_paid": postPaid};

      final response = await apiClient.post(url, body);

      debugPrint("STATUS: ${response.statusCode}");

      try {
        final data = jsonDecode(response.body);
        if (data is Map) {
          final rawMessage = data["message"] ?? data["error"] ?? data["msg"];
          if (rawMessage != null) {
            serverMessage = rawMessage.toString();
          }
        }
      } catch (e) {
        serverMessage = response.body.isNotEmpty
            ? response.body
            : "خطأ في الاتصال بالسيرفر";
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = PackageState.success;
      } else {
        state = PackageState.serverError;
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
