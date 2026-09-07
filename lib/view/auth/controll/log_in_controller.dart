import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:omniya/core/const/url.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/core/services/auth_storage.dart';
import 'package:omniya/core/services/api_error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController with ChangeNotifier {
  bool isLoading = false;

  final AuthStorage storage = AuthStorage();

  final String apilogout = "${AppApi.url}${AppApi.logout}";

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

      final uri = Uri.parse(
        "${AppApi.url}${AppApi.login}",
      );

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
      body.forEach((key, value) {
        debugPrint("$key => $value");
      });
      final languageCode = await _getLanguageCode();

      debugPrint('[LOGIN] REQUEST HEADERS');
      debugPrint('[LOGIN] Accept => application/json');
      debugPrint('[LOGIN] Content-Type => application/json');
      debugPrint('[LOGIN] Accept-Language => $languageCode');
      debugPrint('[LOGIN] Application-type => mobile');
      final response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Accept-Language": languageCode,
          "Application-type": "mobile",
        },
        body: jsonEncode(body),
      );
      isLoading = false;
      notifyListeners();

      debugPrint(
        "STATUS CODE => ${response.statusCode}",
      );

      debugPrint(
        "RESPONSE BODY => ${response.body}",
      );

      Map<String, dynamic>? data;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (e) {
        debugPrint(
          "Response is not valid JSON => $e",
        );
      }

      debugPrint("\nPARSED RESPONSE =>");

      debugPrint(data?.toString() ?? "NULL");

      if (data?["user"] != null) {
        if (data!["user"] is Map) {
          data["user"].forEach((key, value) {
            debugPrint("$key => $value");
          });
        }
      }

      debugPrint(
        "token => ${data?["token"]}",
      );

      debugPrint(
        "refresh_token => ${data?["refresh_token"]}",
      );

      debugPrint(
        "token_expiry => ${data?["token_expiry"]}",
      );

      debugPrint(
        "fcm_registered => ${data?["fcm_registered"]}",
      );

      final savedToken = await storage.getToken();

      final savedRefreshToken = await storage.getRefreshToken();

      final savedExpiry = await storage.storage.read(
        key: "token_expiry",
      );

      debugPrint(
        "saved token => $savedToken",
      );

      debugPrint(
        "saved refresh_token => $savedRefreshToken",
      );

      debugPrint(
        "saved token_expiry => $savedExpiry",
      );

      if (response.statusCode == 200) {
        if (data == null) {
          return LoginResult(
            success: false,
            message: ApiErrorHandler.getUnhandledErrorMessage(
              context: context,
            ),
          );
        }

        await storage.saveToken(
          data["token"],
        );

        await storage.saveRefreshToken(
          data["refresh_token"],
        );

        final tokenAfterLogin = await storage.getToken();

        debugPrint('[LOGIN] SERVER TOKEN');
        debugPrint('${data["token"]}');
        debugPrint('----------------------------------------');
        debugPrint('[LOGIN] STORAGE TOKEN AFTER SAVE');
        debugPrint('$tokenAfterLogin');
        debugPrint(
          '[LOGIN] SAME TOKEN => ${data["token"] == tokenAfterLogin}',
        );

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

      if (response.statusCode == 201) {
        if (data == null) {
          return LoginResult(
            success: false,
            message: ApiErrorHandler.getUnhandledErrorMessage(
              context: context,
            ),
          );
        }

        await storage.saveToken(
          data["token"],
        );

        await storage.saveRefreshToken(
          data["refresh_token"],
        );

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

      if (response.statusCode == 401 ||
          response.statusCode == 406 ||
          response.statusCode == 429) {
        String? serverMessage;

        if (data?["error"] != null) {
          serverMessage = data!["error"].toString();
        } else if (data?["message"] != null) {
          serverMessage = data!["message"].toString();
        }

        debugPrint(
          "SERVER ERROR MESSAGE => $serverMessage",
        );

        return LoginResult(
          success: false,
          message: serverMessage != null && serverMessage.trim().isNotEmpty
              ? serverMessage
              : AppLocalizations.of(context)!.login_failed,
        );
      }
      if (response.statusCode == 426) {
        String? serverMessage;
        String? serverLink;

        if (data?["error"] != null) {
          serverMessage = data!["error"].toString();
        } else if (data?["message"] != null) {
          serverMessage = data!["message"].toString();
        } else if (data?["msg"] != null) {
          serverMessage = data!["msg"].toString();
        }

        if (data?["link"] != null) {
          serverLink = data!["link"].toString().trim();
        }

        debugPrint(
          "426 SERVER ERROR MESSAGE => $serverMessage",
        );

        debugPrint(
          "426 SERVER LINK => $serverLink",
        );

        return LoginResult(
          success: false,
          message: serverMessage != null && serverMessage.trim().isNotEmpty
              ? serverMessage.trim()
              : AppLocalizations.of(context)!.login_failed,
          statusCode: 426,
          link: serverLink,
        );
      }
      if (response.statusCode == 404) {
        return LoginResult(
          success: false,
          message: AppLocalizations.of(context)!.connection_error,
        );
      }

      return LoginResult(
        success: false,
        message: ApiErrorHandler.getUnhandledErrorMessage(
          context: context,
        ),
      );
    } catch (e) {
      isLoading = false;
      notifyListeners();

      debugPrint(
        "Catch Error: $e",
      );

      return LoginResult(
        success: false,
        message: AppLocalizations.of(context)!.connection_error,
      );
    }
  }

  Future<String> _getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString('language');

    if (savedLanguage != null && savedLanguage.trim().isNotEmpty) {
      debugPrint(
        '[LOGIN] LANGUAGE SOURCE => SAVED',
      );

      debugPrint(
        '[LOGIN] SAVED LANGUAGE => $savedLanguage',
      );

      return savedLanguage.trim();
    }
    final deviceLanguage =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();

    final languageCode = deviceLanguage == 'ar' ? 'ar' : 'en';

    debugPrint(
      '[LOGIN] LANGUAGE SOURCE => DEVICE',
    );

    debugPrint(
      '[LOGIN] DEVICE LANGUAGE => $deviceLanguage',
    );

    debugPrint(
      '[LOGIN] LANGUAGE TO SERVER => $languageCode',
    );

    return languageCode;
  }

  Future<bool> logout() async {
    try {
      final token = await storage.getToken();

      debugPrint(
        "Saved Token => $token",
      );

      if (token == null || token.isEmpty) {
        debugPrint(
          "No token found",
        );

        return false;
      }

      final uri = Uri.parse(
        "${AppApi.url}${AppApi.logout}",
      );

      debugPrint(
        "LOGOUT FULL URL => ${uri.toString()}",
      );

      final headers = {
        "Authorization": "Bearer $token",
      };

      debugPrint(
        "LOGOUT URL => $uri",
      );

      headers.forEach((key, value) {
        debugPrint(
          "$key => $value",
        );
      });

      final response = await http.post(
        uri,
        headers: headers,
      );

      debugPrint(
        "STATUS => ${response.statusCode}",
      );

      debugPrint(
        "BODY => ${response.body}",
      );

      try {
        final data = jsonDecode(
          response.body,
        );

        debugPrint(
          "\nPARSED RESPONSE =>",
        );

        if (data is Map) {
          data.forEach((key, value) {
            debugPrint(
              "$key => $value",
            );
          });
        }
      } catch (_) {
        debugPrint(
          "Response is not JSON",
        );
      }

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 401) {
        await storage.clearAuthData();

        await storage.storage.delete(
          key: "token_expiry",
        );

        debugPrint(
          "Logout Success",
        );

        return true;
      }

      debugPrint(
        "Logout Failed",
      );

      return false;
    } catch (e, stack) {
      debugPrint(
        "ERROR => $e",
      );

      debugPrint(
        "STACK => $stack",
      );

      return false;
    }
  }
}

class LoginResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final int? statusCode;
  final String? link;

  LoginResult({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.link,
  });
}
