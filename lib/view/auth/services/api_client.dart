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
    final languageCode = await storage.storage.read(key: "language") ?? "ar";

    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
      "Accept-Language": languageCode,
    };

    print("========== HEADERS ==========");
    print(headers);
    print("=============================");

    return headers;
  }

  Future<http.Response> get(Uri url) async {
    print("========== API REQUEST ==========");
    print("GET URL: $url");
    print("=================================");

    return await _request(
      () async => http.get(url, headers: await _headers()),
    );
  }

  Future<http.Response> post(Uri url, Map body) async {
    print("========== API REQUEST ==========");
    print("POST URL: $url");
    print("BODY: $body");
    print("=================================");

    return await _request(
      () async => http.post(
        url,
        headers: await _headers(),
        body: jsonEncode(body),
      ),
    );
  }

  Future<http.Response> _request(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();

    print("========== API RESPONSE ==========");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    print("==================================");

    if (response.statusCode == 401) {
      if (_isRefreshing) {
        await Future.delayed(const Duration(seconds: 1));
        return await request();
      }

      _isRefreshing = true;
      final refreshed = await authService.refreshToken();
      _isRefreshing = false;

      if (refreshed) {
        return await request();
      }

      await authService.logout();
      throw Exception("SESSION_EXPIRED");
    }

    return response;
  }
}
