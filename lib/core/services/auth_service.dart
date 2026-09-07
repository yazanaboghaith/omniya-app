import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_storage.dart';
import 'package:omniya/core/const/url.dart';

class AuthService {
  final AuthStorage storage = AuthStorage();

  final String refreshUrl = "${AppApi.url}${AppApi.refresh}";

  Future<bool> refreshToken() async {
    debugPrint(
      '[AuthService] ===== REFRESH TOKEN START =====',
    );

    try {
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint(
          '[AuthService] Refresh token is missing.',
        );

        return false;
      }

      debugPrint(
        '[AuthService] Sending refresh token request...',
      );

      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "refresh_token": refreshToken,
        }),
      );

      debugPrint(
        '[AuthService] Refresh response status: '
        '${response.statusCode}',
      );

      debugPrint(
        '[AuthService] Refresh response body: '
        '${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final newToken = data["token"];
        final newRefreshToken = data["refresh_token"];

        if (newToken == null || newToken.toString().isEmpty) {
          debugPrint(
            '[AuthService] Refresh succeeded but token is missing.',
          );

          return false;
        }

        await storage.saveToken(
          newToken.toString(),
        );

        if (newRefreshToken != null && newRefreshToken.toString().isNotEmpty) {
          await storage.saveRefreshToken(
            newRefreshToken.toString(),
          );
        }

        debugPrint(
          '[AuthService] New token saved successfully.',
        );

        debugPrint(
          '[AuthService] ===== REFRESH TOKEN SUCCESS =====',
        );

        return true;
      }

      debugPrint(
        '[AuthService] Refresh token rejected by server.',
      );

      debugPrint(
        '[AuthService] ===== REFRESH TOKEN FAILED =====',
      );

      return false;
    } catch (e, stackTrace) {
      debugPrint(
        '[AuthService] Refresh token error: $e',
      );

      debugPrint(
        '[AuthService] Stack trace: $stackTrace',
      );

      return false;
    }
  }

  Future<void> logout() async {
    debugPrint(
      '[AuthService] Clearing authentication session...',
    );

    await storage.logout();

    debugPrint(
      '[AuthService] Authentication session cleared.',
    );
  }
}
