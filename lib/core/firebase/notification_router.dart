import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:omniya/main.dart';
import 'package:omniya/view/auth/log_in.dart';
import 'package:omniya/core/services/auth_storage.dart';
import 'package:omniya/view/home/notification/notifications.dart';

class NotificationRouter {
  static Future<void> handle(RemoteMessage message) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final storage = AuthStorage();

    final token = await storage.getToken();

    if (token == null || token.isEmpty) {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => Login(
          fromNotification: true,
        ),
      ));
      return;
    }
    if (!context.mounted) return;
    final allowed = await checkSecurity(context);
    if (!allowed) return;

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const Notifications()),
    );
  }

  static Future<bool> checkSecurity(BuildContext context) async {
    final storage = AuthStorage();
    final type = await storage.getSecurityType();

    if (type == "pin") {
      final controller = TextEditingController();

      final result = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("PIN"),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () async {
                final savedPin = await storage.getPin();
                if (!context.mounted) return;
                Navigator.pop(context, controller.text == savedPin);
              },
              child: const Text("دخول"),
            ),
          ],
        ),
      );

      return result ?? false;
    }

    if (type == "bio") {
      final auth = LocalAuthentication();
      return await auth.authenticate(
        localizedReason: "تأكيد الهوية",
      );
    }

    return true;
  }
}
