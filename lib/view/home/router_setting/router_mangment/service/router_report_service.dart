import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:omniya/core/const/url.dart';
import 'package:omniya/core/services/auth_storage.dart';

class RouterReportService {
  final AuthStorage storage = AuthStorage();

  RouterReportService();

  final String apiroutercommandexecute =
      "${AppApi.url}${AppApi.routercommandexecute}";

  Future<bool> sendRouterReport({
    required int routerModelId,
    required Map<String, String> values,
    String? errorMessage,
  }) async {
    final bool hasError =
        errorMessage != null && errorMessage.trim().isNotEmpty;

    final Map<String, dynamic> body = {
      'output': [
        Map<String, dynamic>.from(values),
      ],
      'errorMessage': hasError
          ? [
              errorMessage.trim(),
            ]
          : null,
      'status': hasError ? 0 : 1,
      'router_model_id': routerModelId,
    };

    final Uri url = Uri.parse(apiroutercommandexecute);

    // ============================================================
    // GET SAVED TOKEN
    // ============================================================

    final String? token = await storage.getToken();

    debugPrint('');
    debugPrint('========================================');
    debugPrint('[RouterReportService] TOKEN INFORMATION');
    debugPrint('========================================');

    debugPrint(
      '[RouterReportService] TOKEN EXISTS: '
      '${token != null && token.trim().isNotEmpty}',
    );

    if (token != null && token.trim().isNotEmpty) {
      debugPrint(
        '[RouterReportService] TOKEN LENGTH: ${token.trim().length}',
      );

      debugPrint(
        '[RouterReportService] TOKEN PREVIEW: '
        '${token.trim().length > 10 ? '${token.trim().substring(0, 10)}...' : '********'}',
      );
    } else {
      debugPrint(
        '[RouterReportService] WARNING: TOKEN NOT FOUND',
      );
    }

    // ============================================================
    // HEADERS
    // ============================================================

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    // ============================================================
    // REQUEST LOG
    // ============================================================

    debugPrint('');
    debugPrint('========================================');
    debugPrint('[RouterReportService] SENDING REPORT TO SERVER');
    debugPrint('========================================');

    debugPrint(
      '[RouterReportService] METHOD: POST',
    );

    debugPrint(
      '[RouterReportService] URL: $url',
    );

    debugPrint(
      '[RouterReportService] ROUTER MODEL ID: $routerModelId',
    );

    debugPrint(
      '[RouterReportService] HAS ERROR: $hasError',
    );

    debugPrint(
      '[RouterReportService] VALUES COUNT: ${values.length}',
    );

    // ============================================================
    // VALUES
    // ============================================================

    debugPrint(
      '[RouterReportService] VALUES:',
    );

    values.forEach((key, value) {
      debugPrint(
        '  -> $key = $value',
      );
    });

    // ============================================================
    // ERROR MESSAGE
    // ============================================================

    debugPrint(
      '[RouterReportService] ERROR MESSAGE: '
      '${errorMessage ?? 'null'}',
    );

    // ============================================================
    // STATUS
    // ============================================================

    debugPrint(
      '[RouterReportService] STATUS VALUE: ${hasError ? 0 : 1}',
    );

    // ============================================================
    // HEADERS
    // ============================================================

    debugPrint(
      '[RouterReportService] HEADERS:',
    );

    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        // لا نطبع التوكن الحقيقي لأسباب أمنية
        debugPrint(
          '  -> $key = Bearer ********',
        );
      } else {
        debugPrint(
          '  -> $key = $value',
        );
      }
    });

    // ============================================================
    // JSON BODY
    // ============================================================

    debugPrint(
      '[RouterReportService] JSON BODY:',
    );

    debugPrint(
      const JsonEncoder.withIndent('  ').convert(body),
    );

    // ============================================================
    // SEND REQUEST
    // ============================================================

    try {
      final DateTime requestStart = DateTime.now();

      final http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final Duration duration = DateTime.now().difference(requestStart);

      // ============================================================
      // SERVER RESPONSE
      // ============================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('[RouterReportService] SERVER RESPONSE');
      debugPrint('========================================');

      debugPrint(
        '[RouterReportService] STATUS CODE: ${response.statusCode}',
      );

      debugPrint(
        '[RouterReportService] REASON PHRASE: '
        '${response.reasonPhrase ?? 'null'}',
      );

      debugPrint(
        '[RouterReportService] RESPONSE TIME: '
        '${duration.inMilliseconds} ms',
      );

      // ============================================================
      // RESPONSE HEADERS
      // ============================================================

      debugPrint(
        '[RouterReportService] RESPONSE HEADERS:',
      );

      response.headers.forEach((key, value) {
        debugPrint(
          '  -> $key = $value',
        );
      });

      // ============================================================
      // RESPONSE BODY
      // ============================================================

      debugPrint(
        '[RouterReportService] RESPONSE BODY:',
      );

      debugPrint(
        response.body,
      );

      // ============================================================
      // RESPONSE JSON
      // ============================================================

      if (response.body.trim().isNotEmpty) {
        try {
          final dynamic decodedResponse = jsonDecode(response.body);

          debugPrint(
            '[RouterReportService] RESPONSE JSON:',
          );

          debugPrint(
            const JsonEncoder.withIndent('  ').convert(decodedResponse),
          );
        } catch (_) {
          debugPrint(
            '[RouterReportService] '
            'RESPONSE IS NOT VALID JSON',
          );
        }
      }

      // ============================================================
      // RESULT
      // ============================================================

      final bool success =
          response.statusCode >= 200 && response.statusCode < 300;

      debugPrint(
        '[RouterReportService] REQUEST RESULT: '
        '${success ? 'SUCCESS' : 'FAILED'}',
      );

      return success;
    } catch (e, stackTrace) {
      // ============================================================
      // REQUEST ERROR
      // ============================================================

      debugPrint('');
      debugPrint('========================================');
      debugPrint('[RouterReportService] REQUEST ERROR');
      debugPrint('========================================');

      debugPrint(
        '[RouterReportService] ERROR TYPE: ${e.runtimeType}',
      );

      debugPrint(
        '[RouterReportService] ERROR: $e',
      );

      debugPrint(
        '[RouterReportService] STACK TRACE:',
      );

      debugPrint(
        '$stackTrace',
      );

      return false;
    }
  }
}
