import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';
import 'auth_service.dart';

class ApiClient {
  final AuthStorage storage = AuthStorage();
  final AuthService authService = AuthService();

  bool _isRefreshing = false;

  Future<Map<String, String>> _headers() async {
    final token = await storage.getToken();
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<http.Response> get(Uri url) async {
    return await _request(() async => http.get(url, headers: await _headers()));
  }

  Future<http.Response> post(Uri url, Map body) async {
    return await _request(
      () async =>
          http.post(url, headers: await _headers(), body: jsonEncode(body)),
    );
  }

  Future<http.Response> _request(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();

    if (response.statusCode == 401) {
      print(
        "======> [ApiClient] التوكن منتهي (401)، محاولة التحديث... <======",
      );

      if (_isRefreshing) {
        print(
          "======> [ApiClient] هناك طلب تحديث يعمل حالياً، الانتظار ثانية... <======",
        );
        await Future.delayed(const Duration(seconds: 1));
        return await request();
      }

      _isRefreshing = true;
      final refreshed = await authService.refreshToken();
      _isRefreshing = false;

      if (refreshed) {
        print(
          "======> [ApiClient] تم تحديث التوكن بنجاح! إعادة إرسال الطلب الأصلي... <======",
        );
        return await request();
      }

      print(
        "======> [ApiClient] فشل تحديث الـ Refresh Token، تسجيل الخروج... <======",
      );
      await authService.logout();
      throw Exception("SESSION_EXPIRED");
    }

    return response;
  }
}
