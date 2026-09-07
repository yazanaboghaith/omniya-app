import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_notifier.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/model/data_model.dart';
import 'package:omniya/core/services/api_client.dart';
import 'package:omniya/core/services/api_error_handler.dart';

enum PackageState {
  idle,
  loading,
  success,
  serverError,
  error,
  unauthorized,
}

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

  // ============================================================
  // Get All Packages
  // ============================================================

  Future<void> getallpackage({
    BuildContext? context,
    bool refresh = false,
  }) async {
    debugPrint('[Packages] START request');

    isLoading = true;
    state = PackageState.loading;
    error = null;

    notifyListeners();

    try {
      debugPrint('[Packages] URL: $apiallpackages');

      final response = await apiClient.get(
        Uri.parse(apiallpackages),
      );

      debugPrint(
        '[Packages] STATUS: ${response.statusCode}',
      );

      debugPrint(
        '[Packages] RESPONSE BODY: ${response.body}',
      );

      Map<String, dynamic>? responseData;

      // محاولة تحويل Response إلى JSON
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        } else {
          debugPrint(
            '[Packages] RESPONSE IS NOT A JSON OBJECT',
          );
        }
      } catch (e) {
        debugPrint(
          '[Packages] JSON PARSE ERROR: $e',
        );
      }

      // =========================================================
      // 200 SUCCESS
      // =========================================================

      if (response.statusCode == 200) {
        if (responseData == null) {
          error = context != null
              ? ApiErrorHandler.getUnhandledErrorMessage(
                  context: context,
                )
              : 'Invalid server response';

          state = PackageState.error;

          debugPrint(
            '[Packages] ERROR: Response is not valid JSON object',
          );
        } else {
          try {
            data = DataModel.fromJson(responseData);

            debugPrint(
              '[Packages] DATA PARSED SUCCESSFULLY',
            );

            debugPrint(
              '[Packages] PREPAID COUNT: ${data!.prepaid.length}',
            );

            debugPrint(
              '[Packages] POSTPAID COUNT: ${data!.postpaid.length}',
            );

            state = PackageState.success;
          } catch (e, stackTrace) {
            debugPrint(
              '[Packages] MODEL PARSE ERROR: $e',
            );

            debugPrint(
              '[Packages] STACK TRACE: $stackTrace',
            );

            error = context != null
                ? ApiErrorHandler.getUnhandledErrorMessage(
                    context: context,
                  )
                : 'Failed to process server response';

            state = PackageState.error;
          }
        }
      }

      // =========================================================
      // 401 UNAUTHORIZED
      // =========================================================

      else if (response.statusCode == 401) {
        String? serverMessage;

        if (responseData?['error'] != null) {
          serverMessage = responseData!['error'].toString();
        } else if (responseData?['message'] != null) {
          serverMessage = responseData!['message'].toString();
        } else if (responseData?['msg'] != null) {
          serverMessage = responseData!['msg'].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          error = serverMessage;
        } else if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = 'Unauthorized';
        }

        state = PackageState.unauthorized;

        debugPrint(
          '[Packages] 401 SERVER ERROR => $error',
        );

        if (context != null && context.mounted) {
          AppNotifier.instance.error(
            context,
            error!,
          );
        }
      }

      // =========================================================
      // 406 NOT ACCEPTABLE
      // =========================================================

      else if (response.statusCode == 406) {
        String? serverMessage;

        if (responseData?['error'] != null) {
          serverMessage = responseData!['error'].toString();
        } else if (responseData?['message'] != null) {
          serverMessage = responseData!['message'].toString();
        } else if (responseData?['msg'] != null) {
          serverMessage = responseData!['msg'].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          error = serverMessage;
        } else if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = 'Server Error';
        }

        state = PackageState.serverError;

        debugPrint(
          '[Packages] 406 SERVER ERROR => $error',
        );
      }

      // =========================================================
      // 429 TOO MANY REQUESTS
      // =========================================================

      else if (response.statusCode == 429) {
        String? serverMessage;

        if (responseData?['error'] != null) {
          serverMessage = responseData!['error'].toString();
        } else if (responseData?['message'] != null) {
          serverMessage = responseData!['message'].toString();
        } else if (responseData?['msg'] != null) {
          serverMessage = responseData!['msg'].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          error = serverMessage;
        } else if (context != null) {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          error = 'Server Error';
        }

        state = PackageState.serverError;

        debugPrint(
          '[Packages] 429 SERVER ERROR => $error',
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
          error = 'Server Error';
        }

        state = PackageState.serverError;

        debugPrint(
          '[Packages] UNHANDLED SERVER ERROR => '
          '${response.statusCode}',
        );

        debugPrint(
          '[Packages] ERROR => $error',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        '[Packages] EXCEPTION => $e',
      );

      debugPrint(
        '[Packages] STACK TRACE => $stackTrace',
      );

      if (e.toString().contains('SESSION_EXPIRED')) {
        error = 'Unauthorized - يرجى تسجيل الدخول مرة أخرى';

        state = PackageState.unauthorized;

        if (context != null && context.mounted) {
          AppNotifier.instance.error(
            context,
            'يرجى تسجيل الدخول مرة أخرى',
          );
        }
      } else {
        error = e.toString();

        state = PackageState.error;
      }
    }

    isLoading = false;

    notifyListeners();

    debugPrint(
      '[Packages] END request',
    );
  }

  Future<String> chargeExtraPackage({
    required int addonId,
    required bool isPostPaid,
    BuildContext? context,
  }) async {
    isLoading = true;
    state = PackageState.loading;
    error = null;

    notifyListeners();

    String serverMessage = "";

    try {
      final url = Uri.parse(
        apiPackagesChargeExtraPackage,
      );

      debugPrint(
        "REQUEST URL: $url",
      );

      final Map<String, dynamic> body = {
        "addon_id": addonId,
      };

      if (isPostPaid) {
        body["post_paid"] = "1";
      }

      debugPrint(
        "REQUEST BODY => $body",
      );

      final response = await apiClient.post(
        url,
        body,
      );

      debugPrint(
        "STATUS CODE: ${response.statusCode}",
      );

      debugPrint(
        "RESPONSE BODY: ${response.body}",
      );

      Map<String, dynamic>? responseData;

      try {
        final decoded = jsonDecode(
          response.body,
        );

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;

          debugPrint(
            "DECODED RESPONSE => $responseData",
          );
        }
      } catch (e) {
        debugPrint(
          "JSON PARSE ERROR: $e",
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = PackageState.success;

        debugPrint(
          "STATE: SUCCESS",
        );

        if (responseData != null) {
          final rawMessage = responseData["message"] ?? responseData["msg"];

          if (rawMessage != null) {
            serverMessage = rawMessage.toString().trim();
          }
        }

        error = null;

        debugPrint(
          "SUCCESS SERVER MESSAGE => $serverMessage",
        );
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 406 ||
          response.statusCode == 429) {
        String? message;

        debugPrint(
          "SERVER ERROR STATUS => ${response.statusCode}",
        );

        if (responseData?["error"] != null) {
          message = responseData!["error"].toString();

          debugPrint(
            "MESSAGE SOURCE => error",
          );
        } else if (responseData?["message"] != null) {
          message = responseData!["message"].toString();

          debugPrint(
            "MESSAGE SOURCE => message",
          );
        } else if (responseData?["msg"] != null) {
          message = responseData!["msg"].toString();

          debugPrint(
            "MESSAGE SOURCE => msg",
          );
        }

        if (message != null && message.trim().isNotEmpty) {
          serverMessage = message.trim();

          debugPrint(
            "SERVER MESSAGE FOUND => $serverMessage",
          );
        } else {
          debugPrint(
            "SERVER DID NOT PROVIDE A MESSAGE",
          );

          if (context != null) {
            serverMessage = ApiErrorHandler.getUnhandledErrorMessage(
              context: context,
            );
          } else {
            serverMessage = "Server Error";
          }

          debugPrint(
            "FALLBACK MESSAGE => $serverMessage",
          );
        }

        if (response.statusCode == 401) {
          state = PackageState.unauthorized;

          debugPrint(
            "STATE => UNAUTHORIZED",
          );
        } else {
          state = PackageState.serverError;

          debugPrint(
            "STATE => SERVER ERROR",
          );
        }

        error = serverMessage;

        debugPrint(
          "DISPLAY MESSAGE => $serverMessage",
        );
      } else {
        debugPrint(
          "UNHANDLED SERVER ERROR => ${response.statusCode}",
        );

        if (context != null) {
          serverMessage = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          serverMessage = "Server Error";
        }

        error = serverMessage;

        state = PackageState.serverError;

        debugPrint(
          "ERROR => $serverMessage",
        );

        debugPrint(
          "STATE => SERVER ERROR",
        );
      }
    } catch (e) {
      debugPrint(
        "EXCEPTION => $e",
      );

      if (e.toString().contains("SESSION_EXPIRED")) {
        state = PackageState.unauthorized;

        serverMessage = "انتهت الجلسة، يرجى تسجيل الدخول مجدداً";

        error = serverMessage;

        debugPrint(
          "SESSION EXPIRED",
        );

        debugPrint(
          "MESSAGE => $serverMessage",
        );
      } else {
        state = PackageState.error;

        if (context != null) {
          serverMessage = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        } else {
          serverMessage = "تأكد من اتصالك بالإنترنت وحاول مجدداً";
        }

        error = serverMessage;

        debugPrint(
          "GENERAL EXCEPTION MESSAGE => $serverMessage",
        );

        debugPrint(
          "STATE => ERROR",
        );
      }
    }

    isLoading = false;

    notifyListeners();

    debugPrint(
      "[CHARGE PACKAGE] END",
    );

    debugPrint(
      "FINAL STATE => $state",
    );

    debugPrint(
      "FINAL MESSAGE => $serverMessage",
    );

    return serverMessage;
  }
}
