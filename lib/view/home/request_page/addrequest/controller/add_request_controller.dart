import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omniya/model/service_package.dart';
import 'package:omniya/model/services_response.dart';
import 'package:omniya/view/auth/services/api_client.dart';
import 'package:omniya/const/url.dart';

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
    servicePackages.clear();
    await getServicePackages();
  }

///////////////////////////////
  Future<void> getServicePackages() async {
    debugPrint(" [PACKAGES] START");

    if (isPackagesLoading) {
      debugPrint(" [PACKAGES] Already loading");
      return;
    }

    isPackagesLoading = true;
    notifyListeners();

    debugPrint(" [PACKAGES] URL => $apiservicesupdate");

    try {
      final res = await apiClient.get(Uri.parse(apiservicesupdate));

      debugPrint(" [PACKAGES] STATUS => ${res.statusCode}");
      debugPrint(" [PACKAGES] BODY => ${res.body}");

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);

        debugPrint(" [PACKAGES] JSON parsed");

        final List dataList = jsonData["data"] ?? [];

        servicePackages =
            dataList.map((e) => ServicePackage.fromJson(e)).toList();

        debugPrint(" [PACKAGES] COUNT => ${servicePackages.length}");
      } else {
        packagesError = "فشل في جلب الباقات";
        debugPrint(" [PACKAGES] STATUS NOT 200");
      }
    } catch (e) {
      packagesError = e.toString();
      debugPrint(" [PACKAGES] ERROR => $e");
    }

    isPackagesLoading = false;
    notifyListeners();

    debugPrint(" [PACKAGES] END");
  }

  //////////////////////////
  /////////////////////////
  Future<bool> submitServiceRequest(int serviceId) async {
    debugPrint(" [SUBMIT] START submitServiceRequest");
    debugPrint(" [SUBMIT] serviceId => $serviceId");
    debugPrint(" [SUBMIT] URL => $apiservicesupdate");

    try {
      final body = {
        "new_service_id": serviceId,
      };

      debugPrint(" [SUBMIT] BODY => $body");

      final response = await apiClient.post(
        Uri.parse(apiservicesupdate),
        body,
      );

      debugPrint(" [SUBMIT] RESPONSE RECEIVED");
      debugPrint(" [SUBMIT] STATUS => ${response.statusCode}");
      debugPrint(" [SUBMIT] BODY => ${response.body}");

      final success = response.statusCode == 200 || response.statusCode == 201;

      debugPrint(success ? " [SUBMIT] SUCCESS" : " [SUBMIT] FAILED");

      return success;
    } catch (e) {
      debugPrint(" [SUBMIT] ERROR => $e");
      return false;
    } finally {
      debugPrint(" [SUBMIT] END submitServiceRequest");
    }
  }
}
