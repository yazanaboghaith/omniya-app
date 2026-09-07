import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_storage.dart';
import 'auth_service.dart';
import 'session_manager.dart';

class ApiClient {
  final AuthStorage storage = AuthStorage();
  final AuthService authService = AuthService();

  Future<bool>? _refreshFuture;

  Future<Map<String, String>> _headers() async {
    final token = await storage.getToken();

    debugPrint('[ApiClient] TOKEN USED FOR REQUEST');
    debugPrint('TOKEN EXISTS => ${token != null}');
    debugPrint('TOKEN LENGTH => ${token?.length}');
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString('language') ?? 'ar';

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
      "Accept-Language": languageCode,
    };
  }

  Future<http.Response> get(Uri url) async {
    debugPrint(
      "GET URL: $url",
    );

    final headers = await _headers();

    headers.forEach((key, value) {
      debugPrint(
        "$key : $value",
      );
    });

    return _request(
      () async {
        return http.get(
          url,
          headers: await _headers(),
        );
      },
    );
  }

  Future<http.Response> post(
    Uri url,
    Map body,
  ) async {
    debugPrint(
      "POST URL: $url",
    );

    debugPrint(
      "BODY: $body",
    );

    return _request(
      () async {
        return http.post(
          url,
          headers: await _headers(),
          body: jsonEncode(body),
        );
      },
    );
  }

  Future<http.Response> _request(
    Future<http.Response> Function() request,
  ) async {
    http.Response response;

    try {
      response = await request();
    } catch (e, stackTrace) {
      debugPrint(
        '[ApiClient] REQUEST ERROR: $e',
      );

      debugPrint(
        '[ApiClient] STACK TRACE: $stackTrace',
      );

      rethrow;
    }

    debugPrint(
      "STATUS: ${response.statusCode}",
    );

    debugPrint(
      "BODY: ${response.body}",
    );

    if (response.statusCode == 401) {
      debugPrint(
        '[ApiClient] 401 Unauthorized received.',
      );

      debugPrint(
        '[ApiClient] Starting token refresh...',
      );

      final refreshed = await _refreshToken();

      if (refreshed) {
        debugPrint(
          '[ApiClient] Token refresh succeeded.',
        );

        debugPrint(
          '[ApiClient] Retrying original request...',
        );

        final retryResponse = await request();

        debugPrint(
          '[ApiClient] RETRY STATUS: '
          '${retryResponse.statusCode}',
        );

        debugPrint(
          '[ApiClient] RETRY BODY: '
          '${retryResponse.body}',
        );
        if (retryResponse.statusCode == 401) {
          debugPrint(
            '[ApiClient] Retry still returned 401.',
          );

          await _handleSessionExpired();

          throw Exception(
            "SESSION_EXPIRED",
          );
        }

        return retryResponse;
      }

      debugPrint(
        '[ApiClient] Token refresh failed.',
      );

      await _handleSessionExpired();

      throw Exception(
        "SESSION_EXPIRED",
      );
    }

    return response;
  }

  Future<bool> _refreshToken() async {
    if (_refreshFuture != null) {
      debugPrint(
        '[ApiClient] Waiting for existing refresh operation...',
      );

      return await _refreshFuture!;
    }

    debugPrint(
      '[ApiClient] Creating new refresh operation...',
    );

    _refreshFuture = authService.refreshToken();

    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;

      debugPrint(
        '[ApiClient] Refresh operation finished.',
      );
    }
  }

  Future<void> _handleSessionExpired() async {
    await SessionManager.instance.handleSessionExpired();
  }
}
