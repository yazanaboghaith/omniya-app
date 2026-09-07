import 'package:flutter/foundation.dart';

import 'telnet_command_service.dart';
import 'telnet_connection.dart';
import 'telnet_output_utils.dart';

class TelnetWifiService {
  final TelnetConnection connection;
  final TelnetCommandService commands;

  TelnetWifiService({
    required this.connection,
    required this.commands,
  });

  Future<String> changeWifiPassword(
    String command, {
    Duration timeout = const Duration(seconds: 15),
    String? restartCommand,
  }) async {
    if (!connection.isConnected) {
      debugPrint(
        '[Telnet][WiFi] ❌ Telnet غير متصل بالراوتر.',
      );

      throw StateError(
        'Telnet غير متصل بالراوتر',
      );
    }

    debugPrint(
      '[Telnet][WiFi] CHANGE WIFI PASSWORD',
    );

    debugPrint(
      '[Telnet][WiFi] Command: '
      '${TelnetOutputUtils.hideSensitiveCommand(command)}',
    );

    String output = await commands.execute(
      command,
      timeout: timeout,
      waitForPrompt: true,
    );

    String cleanedOutput =
        TelnetOutputUtils.clean(output);

    String lowerOutput =
        cleanedOutput.toLowerCase();

    debugPrint(
      '[Telnet][WiFi] WIFI PASSWORD DIRECT RESPONSE:',
    );

    debugPrint(cleanedOutput);

    final bool shellRequired =
        _isShellRequiredResponse(lowerOutput);

    if (shellRequired) {
      debugPrint(
        '[Telnet][WiFi]  الراوتر رفض الأمر من الـ prompt الحالي.',
      );

      debugPrint(
        '[Telnet][WiFi]  سيتم الدخول إلى shell باستخدام: sh',
      );

      connection.clearBuffer();

      final shellOutput = await commands.execute(
        'sh',
        timeout: timeout,
        waitForPrompt: true,
      );

      final cleanedShellOutput =
          TelnetOutputUtils.clean(shellOutput);

      debugPrint(
        '[Telnet][WiFi] SHELL RESPONSE:',
      );

      debugPrint(cleanedShellOutput);

      final shellLower =
          cleanedShellOutput.toLowerCase();

      if (_isCommandFailure(shellLower)) {
        debugPrint(
          '[Telnet][WiFi]  فشل الدخول إلى shell.',
        );

        throw StateError(
          'فشل الدخول إلى shell في الراوتر.',
        );
      }

      debugPrint(
        '[Telnet][WiFi]  تم الدخول إلى shell.',
      );

      debugPrint(
        '[Telnet][WiFi]  إعادة تنفيذ أمر تغيير كلمة المرور داخل shell:',
      );

      debugPrint(
        '[Telnet][WiFi] '
        '${TelnetOutputUtils.hideSensitiveCommand(command)}',
      );

      output = await commands.execute(
        command,
        timeout: timeout,
        waitForPrompt: true,
      );

      cleanedOutput =
          TelnetOutputUtils.clean(output);

      lowerOutput =
          cleanedOutput.toLowerCase();

      debugPrint(
        '[Telnet][WiFi] WIFI PASSWORD SHELL RESPONSE:',
      );

      debugPrint(cleanedOutput);

      if (_isCommandFailure(lowerOutput)) {
        debugPrint(
          '[Telnet][WiFi]  تغيير كلمة المرور فشل داخل shell.',
        );

        throw StateError(
          'فشل تغيير كلمة مرور Wi-Fi داخل shell.',
        );
      }

      debugPrint(
        '[Telnet][WiFi]  تم تنفيذ تغيير كلمة المرور داخل shell.',
      );
    } else {
      if (_isCommandFailure(lowerOutput)) {
        debugPrint(
          '[Telnet][WiFi] أمر تغيير كلمة المرور فشل.',
        );

        throw StateError(
          'فشل تغيير كلمة مرور Wi-Fi. '
          'الراوتر رفض الأمر.',
        );
      }

      debugPrint(
        '[Telnet][WiFi]  تم تنفيذ أمر تغيير كلمة المرور مباشرة.',
      );
    }

    if (restartCommand != null &&
        restartCommand.trim().isNotEmpty) {
      debugPrint(
        '[Telnet][WiFi] يوجد أمر restart مطلوب.',
      );

      debugPrint(
        '[Telnet][WiFi] Restart Command: $restartCommand',
      );

      final restartOutput =
          await commands.execute(
        restartCommand,
        timeout: timeout,
        waitForPrompt: true,
      );

      final cleanedRestartOutput =
          TelnetOutputUtils.clean(restartOutput);

      final lowerRestartOutput =
          cleanedRestartOutput.toLowerCase();

      debugPrint(
        '[Telnet][WiFi] WIFI RESTART RESPONSE:',
      );

      debugPrint(cleanedRestartOutput);

      if (_isCommandFailure(lowerRestartOutput)) {
        debugPrint(
          '[Telnet][WiFi]  تغيير كلمة المرور تم، '
          'لكن restart فشل.',
        );

        throw StateError(
          'تم تغيير كلمة مرور Wi-Fi، '
          'لكن فشل تنفيذ أمر إعادة تشغيل Wi-Fi.',
        );
      }

      debugPrint(
        '[Telnet][WiFi]  تم تنفيذ restart بنجاح.',
      );
    } else {
      debugPrint(
        '[Telnet][WiFi] ℹ هذا الراوتر لا يحتاج أمر restart.',
      );
    }


    return cleanedOutput;
  }

  bool _isShellRequiredResponse(String output) {
    final lower = output.toLowerCase();

    if (lower.contains('looking for :')) {
      return true;
    }

    if (lower.contains('looking for:')) {
      return true;
    }

    if (lower.contains('available commands')) {
      return true;
    }

    return false;
  }

  bool _isCommandFailure(String output) {
    final lower = output.toLowerCase();

    const failurePatterns = <String>[
      'unknown command',
      'unknown',
      'invalid command',
      'invalid argument',
      'invalid parameter',
      'command not found',
      'error',
      'failed',
      'failure',
      'syntax error',
      'parameter error',
      'usage:',
      'permission denied',
      'access denied',
    ];

    for (final pattern in failurePatterns) {
      if (lower.contains(pattern)) {
        return true;
      }
    }

    return false;
  }
}
