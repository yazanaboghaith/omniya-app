import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omniya/model/service_package.dart';
import 'package:omniya/model/services_response.dart';
import 'package:omniya/core/services/api_client.dart';
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
    debugPrint(" [REFRESH] Clearing list and fetching again...");
    servicePackages.clear();
    await getServicePackages();
  }

  Future<void> getServicePackages() async {
    debugPrint(" [PACKAGES] START");

    if (isPackagesLoading) {
      debugPrint(" [PACKAGES] Already loading... skipping");
      return;
    }

    isPackagesLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get(Uri.parse(apiservicesupdate));

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        final List dataList = jsonData["data"] ?? [];

        servicePackages =
            dataList.map((e) => ServicePackage.fromJson(e)).toList();
      } else {
        packagesError = "failed_fetch_data";
        debugPrint(" [PACKAGES] STATUS NOT 200");
      }
    } catch (e) {
      packagesError = "server_error_message";
      debugPrint(" [PACKAGES] ERROR => $e");
    }

    isPackagesLoading = false;
    notifyListeners();
  }

  Future<bool> submitServiceRequest(int serviceId, BuildContext context) async {
    final l10 = AppLocalizations.of(context)!;

    debugPrint(" [SUBMIT] START submitServiceRequest");

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

      String secureUrl = actionDetails.url.replaceAll("http://", "https://");

      final response = await apiClient.post(
        Uri.parse(secureUrl),
        actionDetails.body,
      );

      final success = response.statusCode == 200 || response.statusCode == 201;

      debugPrint(success ? " [SUBMIT] SUCCESS" : " [SUBMIT] FAILED");
      return success;
    } catch (e) {
      debugPrint(" [SUBMIT] EXCEPTION ERROR => $e");
      return false;
    }
  }
}
