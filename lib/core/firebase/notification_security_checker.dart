import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

import 'package:omniya/core/services/auth_storage.dart';
import 'package:omniya/core/services/session_manager.dart';

class NotificationSecurityChecker {
  NotificationSecurityChecker._();

  static final NotificationSecurityChecker instance =
      NotificationSecurityChecker._();

  final LocalAuthentication _auth = LocalAuthentication();

  final AuthStorage _storage = AuthStorage();

  Future<bool> check() async {
    debugPrint(
      '[NotificationSecurityChecker] START',
    );

    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      debugPrint(
        '[NotificationSecurityChecker] NO USER TOKEN',
      );

      return false;
    }

    final type = await _storage.getSecurityType();

    debugPrint(
      '[NotificationSecurityChecker] SECURITY TYPE => $type',
    );


    if (type == 'pin') {
      return await _checkPin();
    }


    if (type == 'bio') {
      return await _checkBiometric();
    }


    debugPrint(
      '[NotificationSecurityChecker] NO SECURITY ENABLED',
    );

    return true;
  }

  Future<bool> _checkPin() async {
    debugPrint(
      '[NotificationSecurityChecker] PIN CHECK START',
    );

    final context = SessionManager.instance.navigatorKey.currentContext;

    if (context == null) {
      debugPrint(
        '[NotificationSecurityChecker] CONTEXT IS NULL',
      );

      return false;
    }

    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.enter_pin,
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                false,
              );
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                controller.text == '1234',
              );
            },
            child: Text(
              AppLocalizations.of(context)!.login,
            ),
          ),
        ],
      ),
    );

    controller.dispose();

    debugPrint(
      '[NotificationSecurityChecker] PIN RESULT => $result',
    );

    return result ?? false;
  }

  Future<bool> _checkBiometric() async {
    debugPrint(
      '[NotificationSecurityChecker] BIOMETRIC CHECK START',
    );

    try {
      final context = SessionManager.instance.navigatorKey.currentContext;

      final authenticated = await _auth.authenticate(
        localizedReason: context != null
            ? AppLocalizations.of(context)!.identity_verification
            : 'Identity verification',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      debugPrint(
        '[NotificationSecurityChecker] '
        'BIOMETRIC RESULT => $authenticated',
      );

      return authenticated;
    } catch (e, stackTrace) {
      debugPrint(
        '[NotificationSecurityChecker] '
        'BIOMETRIC ERROR => $e',
      );

      debugPrint(
        '[NotificationSecurityChecker] '
        'STACK => $stackTrace',
      );

      return false;
    }
  }
}
