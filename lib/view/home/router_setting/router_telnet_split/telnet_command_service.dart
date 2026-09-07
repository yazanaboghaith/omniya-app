import 'dart:async';

import 'package:flutter/foundation.dart';

import 'telnet_connection.dart';
import 'telnet_constants.dart';
import 'telnet_output_utils.dart';
import 'telnet_login_service.dart';

//////////////////////////////////////
///////////////////////////////////////
/////////////////////////////////////////
///////////////////////////////////////
/////جلب القيم من الراوتر هنا
///////////////////////////////////////
/////////////////////////////////////////
///////////////////////////////////////
class TelnetCommandService {
  final TelnetConnection connection;
  final TelnetLoginService loginService;

  Future<void>? _operationLock;
  bool _isExecuting = false;

  TelnetCommandService({
    required this.connection,
    required this.loginService,
  });

  Future<T> _withLock<T>(
    Future<T> Function() operation,
  ) async {
    while (_operationLock != null) {
      try {
        await _operationLock;
      } catch (_) {}
    }

    final completer = Completer<void>();
    _operationLock = completer.future;

    try {
      return await operation();
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }

      if (identical(
        _operationLock,
        completer.future,
      )) {
        _operationLock = null;
      }
    }
  }

  Future<String> execute(
    String command, {
    Duration timeout = TelnetConstants.commandTimeout,
    bool waitForPrompt = true,
  }) async {
    return _withLock<String>(
      () async {
        if (!connection.isConnected) {
          debugPrint(
            '[Telnet][Command]  Cannot execute: not connected.',
          );

          throw StateError(
            'Telnet connection is not established.',
          );
        }

        if (loginService.isLoggingIn) {
          debugPrint(
            '[Telnet][Command]  Cannot execute while logging in.',
          );

          throw StateError(
            'Cannot execute a command while logging in.',
          );
        }

        if (_isExecuting) {
          debugPrint(
            '[Telnet][Command]  Another command is already executing.',
          );

          throw StateError(
            'A Telnet command is already executing.',
          );
        }

        _isExecuting = true;

        final safeCommand = TelnetOutputUtils.hideSensitiveCommand(command);

        debugPrint(
          '[Telnet][Command]  Executing: $safeCommand',
        );

        try {
          connection.clearBuffer();

          await connection.send(command);

          debugPrint(
            '[Telnet][Command] Command sent. Waiting for response...',
          );

          final output = waitForPrompt
              ? await connection.waitForPrompt(
                  timeout: timeout,
                )
              : await connection.waitForOutput(
                  timeout: timeout,
                );

          debugPrint(
            '[Telnet][Command]  Command completed successfully.',
          );

          return output;
        } catch (e) {
          debugPrint(
            '[Telnet][Command]  Command failed: $e',
          );
          rethrow;
        } finally {
          _isExecuting = false;
        }
      },
    );
  }

  Future<String> getLineStatistics(
    String command, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (!connection.isConnected) {
      debugPrint(
        '[Telnet][Statistics]  Telnet غير متصل بالراوتر.',
      );

      throw StateError(
        'Telnet غير متصل بالراوتر',
      );
    }

    debugPrint(
      '[Telnet][Statistics] جاري جلب Line Statistics...',
    );

    try {
      final output = await execute(
        command,
        timeout: timeout,
        waitForPrompt: true,
      );

      debugPrint(
        '[Telnet][Statistics]  تم جلب Line Statistics بنجاح.',
      );

      return output;
    } catch (e) {
      debugPrint(
        '[Telnet][Statistics]  فشل جلب Line Statistics: $e',
      );
      rethrow;
    }
  }
}
