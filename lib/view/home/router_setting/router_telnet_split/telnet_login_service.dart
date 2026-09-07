import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:omniya/view/home/router_setting/router_telnet_split/handle_error/telnet_error.dart';

import 'telnet_connection.dart';
import 'telnet_constants.dart';
import 'telnet_output_utils.dart';
import 'telnet_prompt_detector.dart';

class TelnetLoginService {
  final TelnetConnection connection;

  bool _isLoggingIn = false;

  TelnetLoginService(this.connection);

  bool get isLoggingIn => _isLoggingIn;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    debugPrint('[Telnet][Login] بدء تسجيل الدخول');

    if (!connection.isConnected) {
      debugPrint('[Telnet][Login] لا يوجد اتصال Telnet');

      throw const TelnetLoginException(
        TelnetErrorType.gatewayNotFound,
      );
    }

    if (_isLoggingIn) {
      debugPrint('[Telnet][Login] عملية تسجيل دخول قيد التنفيذ');

      throw const TelnetLoginException(
        TelnetErrorType.unknown,
      );
    }

    _isLoggingIn = true;

    try {
      await _loginInternal(
        username: username,
        password: password,
      );

      debugPrint('[Telnet][Login] تم تسجيل الدخول بنجاح');
    } on TelnetLoginException catch (e) {
      debugPrint(
        '[Telnet][Login] فشل تسجيل الدخول: ${e.type}',
      );

      rethrow;
    } on SocketException catch (e) {
      debugPrint(
        '[Telnet][Login] SocketException: ${e.message}',
      );

      throw _mapSocketException(e);
    } on TimeoutException {
      debugPrint('[Telnet][Login] انتهت مهلة الاتصال');

      throw const TelnetLoginException(
        TelnetErrorType.connectionTimeout,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[Telnet][Login] خطأ غير معروف: $e',
      );

      debugPrint(
        '[Telnet][Login] StackTrace: $stackTrace',
      );

      throw const TelnetLoginException(
        TelnetErrorType.unknown,
      );
    } finally {
      _isLoggingIn = false;

      debugPrint('[Telnet][Login] انتهاء تسجيل الدخول');
    }
  }

  Future<void> _loginInternal({
    required String username,
    required String password,
  }) async {
    final initial = await connection.waitForLoginToken(
      timeout: TelnetConstants.loginTimeout,
    );

    final cleanInitial = TelnetOutputUtils.clean(initial);

    debugPrint('[Telnet][Login] استلام الاستجابة الأولية');

    if (TelnetPromptDetector.hasPrompt(cleanInitial)) {
      connection.clearBuffer();
      return;
    }

    bool usernameSent = false;
    bool passwordSent = false;

    int passwordAttempts = 0;
    int emptyBufferCount = 0;

    final loginStart = DateTime.now();

    while (
        DateTime.now().difference(loginStart) < const Duration(seconds: 20)) {
      final snapshot = TelnetOutputUtils.clean(
        connection.currentBuffer,
      );

      final lower = snapshot.toLowerCase();

      if (TelnetPromptDetector.hasPrompt(snapshot)) {
        debugPrint('[Telnet][Login] تم اكتشاف Prompt');

        connection.clearBuffer();
        return;
      }

      if (TelnetPromptDetector.containsPasswordPrompt(lower)) {
        if (passwordAttempts >= 3) {
          debugPrint(
            '[Telnet][Login] تجاوز عدد محاولات كلمة المرور',
          );

          connection.clearBuffer();

          throw const TelnetLoginException(
            TelnetErrorType.invalidCredentials,
          );
        }

        passwordAttempts++;

        connection.clearBuffer();

        debugPrint(
          '[Telnet][Login] إرسال كلمة المرور',
        );

        try {
          await connection.send(password);
        } on SocketException catch (e) {
          throw _mapSocketException(e);
        }

        passwordSent = true;

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        continue;
      }

      if (TelnetPromptDetector.containsUsernamePrompt(lower)) {
        if (!usernameSent) {
          connection.clearBuffer();

          debugPrint(
            '[Telnet][Login] إرسال اسم المستخدم',
          );

          try {
            await connection.send(username);
          } on SocketException catch (e) {
            throw _mapSocketException(e);
          }

          usernameSent = true;

          await Future.delayed(
            const Duration(milliseconds: 500),
          );

          continue;
        }

        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      }

      if (TelnetPromptDetector.isLoginFailure(lower)) {
        debugPrint(
          '[Telnet][Login] فشل بيانات تسجيل الدخول',
        );

        connection.clearBuffer();

        throw const TelnetLoginException(
          TelnetErrorType.invalidCredentials,
        );
      }

      if (snapshot.isEmpty) {
        emptyBufferCount++;

        if (emptyBufferCount % 5 == 0) {
          await _wakeRouter();
        }

        await Future.delayed(
          const Duration(milliseconds: 200),
        );

        continue;
      }

      if (passwordSent) {
        await Future.delayed(
          const Duration(milliseconds: 200),
        );

        continue;
      }

      if (TelnetPromptDetector.looksLikePasswordRequest(lower)) {
        connection.clearBuffer();

        debugPrint(
          '[Telnet][Login] إرسال كلمة المرور',
        );

        try {
          await connection.send(password);
        } on SocketException catch (e) {
          throw _mapSocketException(e);
        }

        passwordSent = true;

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        continue;
      }

      if (TelnetPromptDetector.looksLikeUsernameRequest(lower)) {
        if (!usernameSent) {
          connection.clearBuffer();

          debugPrint(
            '[Telnet][Login] إرسال اسم المستخدم',
          );

          try {
            await connection.send(username);
          } on SocketException catch (e) {
            throw _mapSocketException(e);
          }

          usernameSent = true;

          await Future.delayed(
            const Duration(milliseconds: 500),
          );

          continue;
        }
      }

      await Future.delayed(
        const Duration(milliseconds: 300),
      );
    }

    final finalOutput = TelnetOutputUtils.clean(
      connection.currentBuffer,
    );

    debugPrint(
      '[Telnet][Login] انتهت مهلة تسجيل الدخول',
    );

    if (TelnetPromptDetector.hasPrompt(finalOutput)) {
      connection.clearBuffer();
      return;
    }

    if (TelnetPromptDetector.isLoginFailure(
      finalOutput.toLowerCase(),
    )) {
      connection.clearBuffer();

      throw const TelnetLoginException(
        TelnetErrorType.invalidCredentials,
      );
    }

    connection.clearBuffer();

    throw const TelnetLoginException(
      TelnetErrorType.connectionTimeout,
    );
  }

  Future<void> _wakeRouter() async {
    try {
      await connection.send(
        '',
        enter: true,
      );
    } on SocketException catch (e) {
      debugPrint(
        '[Telnet][Login] فشل Wake: ${e.message}',
      );
    } catch (e) {
      debugPrint(
        '[Telnet][Login] فشل Wake: $e',
      );
    }
  }

  TelnetLoginException _mapSocketException(
    SocketException e,
  ) {
    final message = e.message.toLowerCase();

    debugPrint(
      '[Telnet][Login] تحليل خطأ الاتصال',
    );

    if (message.contains('connection refused')) {
      return const TelnetLoginException(
        TelnetErrorType.connectionRefused,
      );
    }

    if (message.contains('connection reset')) {
      return const TelnetLoginException(
        TelnetErrorType.telnetUnavailable,
      );
    }

    if (message.contains('timed out') || message.contains('timeout')) {
      return const TelnetLoginException(
        TelnetErrorType.connectionTimeout,
      );
    }

    if (message.contains('network is unreachable')) {
      return const TelnetLoginException(
        TelnetErrorType.networkUnreachable,
      );
    }

    if (message.contains('host is unreachable')) {
      return const TelnetLoginException(
        TelnetErrorType.hostUnreachable,
      );
    }

    if (message.contains('failed host lookup') ||
        message.contains('unknown host') ||
        message.contains('host lookup')) {
      return const TelnetLoginException(
        TelnetErrorType.hostLookupFailed,
      );
    }

    return const TelnetLoginException(
      TelnetErrorType.unknown,
    );
  }
}
