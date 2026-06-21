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

  AddonServiceResponse? response;
  List<AddonServiceModel> addons = [];

  final String url = "${AppApi.url}${AppApi.servicesaddon}";
  final String apiservicesupdate = "${AppApi.url}${AppApi.servicesupdate}";
  // =========================================================
  // GET ADDON SERVICES
  // =========================================================
  Future<void> getAddonServices() async {
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await apiClient.get(Uri.parse(url));

      debugPrint("STATUS => ${res.statusCode}");
      debugPrint("BODY => ${res.body}");

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        if (jsonData == null || jsonData["data"] == null) {
          addons = [];
        } else {
          response = AddonServiceResponse.fromJson(jsonData);
          addons = response?.data ?? [];
        }

        debugPrint("ADDONS COUNT => ${addons.length}");
      } else {
        error = "فشل في جلب البيانات";
        addons = [];
      }
    } catch (e) {
      error = e.toString();
      addons = [];
      debugPrint("EXCEPTION => $e");
    }

    isLoading = false;
    notifyListeners();
  }
///////////////////////////
  Future<void> refresh() async {
    addons.clear();
    await getAddonServices();
  }
///////////////////////////////
  Future<void> getServicesPackageUpdate() async {
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await apiClient.get(
        Uri.parse(apiservicesupdate),
      );

      debugPrint("STATUS => ${res.statusCode}");
      debugPrint("BODY => ${res.body}");

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);

        if (jsonData == null || jsonData["data"] == null) {
          addons = [];
          response = null;
        } else {
          final parsed = ServicesPackageResponse.fromJson(jsonData);
          addons = parsed.data
              .map((e) => AddonServiceModel(
                    id: e.id,
                    name: e.name,
                    regPrice: e.regPrice,
                  ))
              .toList();

          debugPrint("SERVICES PACKAGE COUNT => ${addons.length}");
        }
      } else {
        error = "فشل في جلب البيانات (services package update)";
        addons = [];
      }
    } catch (e) {
      error = e.toString();
      addons = [];
      debugPrint("EXCEPTION (services package update) => $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
