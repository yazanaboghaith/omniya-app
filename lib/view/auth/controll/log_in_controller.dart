import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:omniya/const/url.dart';
import 'package:omniya/view/auth/services/auth_storage.dart';

class LoginController with ChangeNotifier {
  bool isLoading = false;
  final AuthStorage storage = AuthStorage();

  Future<LoginResult> login({
    required String username,
    required String password,
    required int remember,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      print("======> [Controller] إرسال طلب تسجيل الدخول... <======");
      final uri = Uri.parse("${AppApi.Url}${AppApi.login}");

      final body = {
        "username": username,
        "password": password,
        "remember_me": remember.toString() == "1" ? "1" : "0",
      };

      print("======> [Controller] Body: $body <======");

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

      print("======> [Controller] Status Code: ${response.statusCode} <======");
      print("======> [Controller] Response Body: ${response.body} <======");

      isLoading = false;
      notifyListeners();

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("======> [Controller] الدخول صحيح، جاري حفظ التوكن... <======");

        // ✅ التعديل هنا: حماية التطبيق من القيم الـ null القادمة من السيرفر
        await storage.saveToken(data["token"] ?? "");
        await storage.saveRefreshToken(data["refresh_token"] ?? "");
        await storage.storage.write(key: "last_username", value: username);

        return LoginResult(
          success: true,
          message: "تم تسجيل الدخول بنجاح",
          data: data,
        );
      }

      print("======> [Controller] فشل الدخول: ${data["message"]} <======");
      return LoginResult(
        success: false,
        message: data["message"] ?? "فشل تسجيل الدخول",
      );
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print("======> [Controller] خطأ (Catch): $e <======");

      return LoginResult(
        success: false,
        message: "حدث خطأ في الاتصال بالسيرفر",
      );
    }
  }
}

class LoginResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  LoginResult({required this.success, required this.message, this.data});
}
