import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:omniya/core/const/url.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/core/services/auth_storage.dart';

class LoginController with ChangeNotifier {
  bool isLoading = false;
  final AuthStorage storage = AuthStorage();
  final String apilogout = "${AppApi.url}${AppApi.logout}";
  /////////////////////////////
  ////////////////////////////
  ////////////////////////////
  ///////////////////////////
  Future<LoginResult> login({
    required String username,
    required String password,
    required String remember,
    required String fcmToken,
    required String deviceType,
    required String deviceName,
    required BuildContext context,
    // required String deviceUuid,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final uri = Uri.parse("${AppApi.url}${AppApi.login}");

      final body = {
        "username": username,
        "password": password,
        "remember_me": remember,
        "fcm_token": fcmToken,
        "device_type": deviceType,
        "device_name": deviceName,
        // "device_uuid": deviceUuid,
      };

      debugPrint(jsonEncode(body));

      debugPrint("\n======> RAW BODY MAP <======");
      body.forEach((key, value) {
        debugPrint("$key => $value");
      });

      final response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Accept-Language": "ar",
          "Application-type": "mobile",
        },
        body: jsonEncode(body),
      );

      isLoading = false;
      notifyListeners();

      debugPrint("STATUS CODE => ${response.statusCode}");

      debugPrint(response.body);

      final data = jsonDecode(response.body);

      debugPrint("\nPARSED RESPONSE =>");
      debugPrint(data.toString());
      if (data["user"] != null) {
        debugPrint("\n====== USER DATA ======");
        data["user"].forEach((key, value) {
          debugPrint("$key => $value");
        });
      }

      debugPrint("token => ${data["token"]}");
      debugPrint("refresh_token => ${data["refresh_token"]}");
      debugPrint("token_expiry => ${data["token_expiry"]}");
      debugPrint("fcm_registered => ${data["fcm_registered"]}");

      debugPrint("\n================ LOGIN END ================\n");
      final savedToken = await storage.getToken();
      final savedRefreshToken = await storage.getRefreshToken();
      final savedExpiry = await storage.storage.read(
        key: "token_expiry",
      );

      debugPrint("saved token => $savedToken");
      debugPrint("saved refresh_token => $savedRefreshToken");
      debugPrint("saved token_expiry => $savedExpiry");
      if (response.statusCode == 200) {
        debugPrint("======> SAVING TOKENS TO STORAGE <======");

        await storage.saveToken(data["token"]);

        await storage.saveRefreshToken(data["refresh_token"]);

        await storage.storage.write(
          key: "last_username",
          value: username,
        );

        await storage.storage.write(
          key: "token_expiry",
          value: data["token_expiry"].toString(),
        );

        return LoginResult(
          success: true,
          message: AppLocalizations.of(context)!.login_success,
          data: data,
        );
      }

      final errorMessage = data["message"] ??
          data["error"] ??
          data["errors"]?.toString() ??
          AppLocalizations.of(context)!.login_failed;

      // debugPrint("ERROR MESSAGE:${errorMessage}");

      return LoginResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      isLoading = false;
      notifyListeners();

      debugPrint("Catch Error: $e");

      return LoginResult(
        success: false,
        message: AppLocalizations.of(context)!.connection_error,
      );
    }
  }

/////////////////////////////
//////////////////////////////
/////////////////////////////
//////////////////////////////
////////////////////////////
  Future<bool> logout() async {
    try {
      debugPrint("\n========== LOGOUT START ==========");

      final token = await storage.getToken();

      debugPrint("Saved Token => $token");

      if (token == null || token.isEmpty) {
        debugPrint("No token found");
        return false;
      }

      final uri = Uri.parse("${AppApi.url}${AppApi.logout}");
      debugPrint("LOGOUT FULL URL => ${uri.toString()}");
      final headers = {
        // "Accept": "application/json",
        // "Content-Type": "application/json",
        // "Accept-Language": "ar",
        "Authorization": "Bearer $token",
      };

      debugPrint("LOGOUT URL => $uri");

      headers.forEach((key, value) {
        debugPrint("$key => $value");
      });

      final response = await http.post(
        uri,
        headers: headers,
      );

      debugPrint("\n========== LOGOUT RESPONSE ==========");
      debugPrint("STATUS => ${response.statusCode}");
      debugPrint("BODY => ${response.body}");

      try {
        final data = jsonDecode(response.body);

        debugPrint("\nPARSED RESPONSE =>");

        data.forEach((key, value) {
          debugPrint("$key => $value");
        });
      } catch (_) {
        debugPrint("Response is not JSON");
      }

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 401) {
        debugPrint("\n====== CLEARING STORAGE ======");

        await storage.clearAuthData();
        await storage.storage.delete(key: "token_expiry");

        debugPrint("Storage cleared successfully");
        debugPrint("Logout Success");
        debugPrint("================================\n");

        return true;
      }

      debugPrint("Logout Failed");
      return false;
    } catch (e, stack) {
      debugPrint("\n========== LOGOUT ERROR ==========");
      debugPrint("ERROR => $e");
      debugPrint("STACK => $stack");
      debugPrint("==================================\n");

      return false;
    }
  }
}

class LoginResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  LoginResult({
    required this.success,
    required this.message,
    this.data,
  });
}
