import 'package:flutter/material.dart';

import 'package:omniya/core/const/app_notifier.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/view/auth/log_in.dart';

import 'auth_storage.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final AuthStorage storage = AuthStorage();

  bool _handlingSessionExpired = false;

  Future<void> handleSessionExpired() async {
    if (_handlingSessionExpired) {
      debugPrint(
        '[SessionManager] Session expiration is already being handled.',
      );
      return;
    }

    _handlingSessionExpired = true;

    debugPrint(
      '[SessionManager] ===== SESSION EXPIRED =====',
    );

    try {

      debugPrint(
        '[SessionManager] Clearing authentication data...',
      );

      await storage.logout();

      debugPrint(
        '[SessionManager] Authentication data cleared.',
      );

      final navigator = navigatorKey.currentState;

      if (navigator == null) {
        debugPrint(
          '[SessionManager] Navigator state is null.',
        );

        return;
      }

      debugPrint(
        '[SessionManager] Navigator state is available.',
      );


      debugPrint(
        '[SessionManager] Navigating to Login...',
      );

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const Login(),
        ),
        (route) => false,
      );

      debugPrint(
        '[SessionManager] Navigation to Login completed.',
      );


      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      final context = navigatorKey.currentContext;

      if (context == null) {
        debugPrint(
          '[SessionManager] Context is null after navigation.',
        );

        return;
      }

      final l10n = AppLocalizations.of(context);

      if (l10n == null) {
        debugPrint(
          '[SessionManager] AppLocalizations is null.',
        );

        return;
      }

      debugPrint(
        '[SessionManager] Showing session expired notification...',
      );

      AppNotifier.instance.show(
        context: context,
        title: l10n.session_expired_title,
        message: l10n.session_expired_message,
        isSuccess: false,
        buttonText: l10n.login,
      );

      debugPrint(
        '[SessionManager] Session expired notification shown.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[SessionManager] ERROR: $e',
      );

      debugPrint(
        '[SessionManager] STACK TRACE: $stackTrace',
      );
    } finally {
      _handlingSessionExpired = false;
    }
  }
}
