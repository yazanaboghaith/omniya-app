import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omniya/model/service_package.dart';
import 'package:omniya/model/services_response.dart';
import 'package:omniya/core/services/api_client.dart';
import 'package:omniya/core/services/api_error_handler.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

class AddonServiceController with ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  bool isLoading = false;
  String? error;

  List<ServicePackage> servicePackages = [];

  bool isPackagesLoading = false;
  String? packagesError;

  AddonServiceResponse? response;

  List<AddonServiceModel> addons = [];

  final String apiservicesupdate = "${AppApi.url}${AppApi.servicesupdate}";

  Future<void> refreshServicePackages() async {
    debugPrint(
      " [REFRESH] Clearing list and fetching again...",
    );

    servicePackages.clear();

    await getServicePackages();
  }

  Future<void> getServicePackages() async {
    debugPrint(" [PACKAGES] START");

    if (isPackagesLoading) {
      debugPrint(
        " [PACKAGES] Already loading... skipping",
      );

      return;
    }

    isPackagesLoading = true;
    packagesError = null;

    notifyListeners();

    try {
      final res = await apiClient.get(
        Uri.parse(apiservicesupdate),
      );

      debugPrint(
        " [PACKAGES] STATUS CODE => ${res.statusCode}",
      );

      debugPrint(
        " [PACKAGES] RESPONSE BODY => ${res.body}",
      );

      Map<String, dynamic>? responseData;

      try {
        final decoded = json.decode(res.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          " [PACKAGES] Response is not valid JSON => $e",
        );
      }

      // ============================================================
      // 200 - Success
      // ============================================================

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);

        final List dataList = jsonData["data"] ?? [];

        servicePackages = dataList
            .map(
              (e) => ServicePackage.fromJson(e),
            )
            .toList();

        debugPrint(
          " [PACKAGES] SUCCESS => ${servicePackages.length} packages",
        );
      }

      // ============================================================
      // 401 - Unauthorized
      // ============================================================

      else if (res.statusCode == 401) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          packagesError = serverMessage;
        } else {
          packagesError = "غير مصرح لك بالوصول";
        }

        debugPrint(
          " [PACKAGES] 401 SERVER ERROR => $packagesError",
        );
      }

      // ============================================================
      // 406 - Not Acceptable
      // ============================================================

      else if (res.statusCode == 406) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          packagesError = serverMessage;
        } else {
          packagesError = "server_error_message";
        }

        debugPrint(
          " [PACKAGES] 406 SERVER ERROR => $packagesError",
        );
      }

      // ============================================================
      // 429 - Too Many Requests
      // ============================================================

      else if (res.statusCode == 429) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          packagesError = serverMessage;
        } else {
          packagesError = "server_error_message";
        }

        debugPrint(
          " [PACKAGES] 429 SERVER ERROR => $packagesError",
        );
      }

      // ============================================================
      // Other Server Errors
      // ============================================================

      else {
        packagesError = "server_error_message";

        debugPrint(
          " [PACKAGES] UNHANDLED STATUS => ${res.statusCode}",
        );
      }
    } catch (e) {
      packagesError = "server_error_message";

      debugPrint(
        " [PACKAGES] ERROR => $e",
      );
    }

    isPackagesLoading = false;

    notifyListeners();
  }

  Future<bool> submitServiceRequest(
    int serviceId,
    BuildContext context,
  ) async {
    final l10 = AppLocalizations.of(context)!;

    debugPrint(
      " [SUBMIT] START submitServiceRequest",
    );

    try {
      final package = servicePackages.firstWhere(
        (pkg) => pkg.id == serviceId,
        orElse: () => throw Exception(l10.error),
      );

      if (package.actions.isEmpty) {
        throw Exception(l10.error);
      }

      final actionItem = package.actions.first;

      final actionDetails = actionItem.create ?? actionItem.remove;

      if (actionDetails == null) {
        throw Exception(l10.error);
      }

      String secureUrl = actionDetails.url.replaceAll(
        "http://",
        "https://",
      );

      final response = await apiClient.post(
        Uri.parse(secureUrl),
        actionDetails.body,
      );

      debugPrint(
        " [SUBMIT] STATUS CODE => ${response.statusCode}",
      );

      debugPrint(
        " [SUBMIT] RESPONSE BODY => ${response.body}",
      );

      // ============================================================
      // 200 / 201 - Success
      // ============================================================

      final success = response.statusCode == 200 || response.statusCode == 201;

      if (success) {
        debugPrint(
          " [SUBMIT] SUCCESS",
        );

        return true;
      }

      // ============================================================
      // Parse server response
      // ============================================================

      Map<String, dynamic>? responseData;

      try {
        final decoded = json.decode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (e) {
        debugPrint(
          " [SUBMIT] Response is not valid JSON => $e",
        );
      }

      if (response.statusCode == 401 ||
          response.statusCode == 406 ||
          response.statusCode == 403 ||
          response.statusCode == 429) {
        String? serverMessage;

        if (responseData?["error"] != null) {
          serverMessage = responseData!["error"].toString();
        } else if (responseData?["message"] != null) {
          serverMessage = responseData!["message"].toString();
        }

        if (serverMessage != null && serverMessage.trim().isNotEmpty) {
          error = serverMessage;
        } else {
          error = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );
        }

        debugPrint(
          " [SUBMIT] SERVER ERROR => $error",
        );

        return false;
      }

      // ============================================================
      // Other Errors
      // ============================================================

      error = ApiErrorHandler.getUnhandledErrorMessage(
        context: context,
      );

      debugPrint(
        " [SUBMIT] UNHANDLED SERVER ERROR => "
        "${response.statusCode}",
      );

      debugPrint(
        " [SUBMIT] ERROR MESSAGE => $error",
      );

      return false;
    } catch (e) {
      debugPrint(
        " [SUBMIT] EXCEPTION ERROR => $e",
      );

      error = l10.error;

      return false;
    }
  }
}
