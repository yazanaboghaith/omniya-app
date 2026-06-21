import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Function(String)? onTrackOpen;
  static Function(String)? onNavigate;
  static Future init({
    Function(String)? trackOpenCallback,
    Function(String)? navigateCallback,
  }) async {
    onTrackOpen = trackOpenCallback;
    onNavigate = navigateCallback;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        _onNotificationClick(details.payload);
      },
    );
  }

  static Future showNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? '';

    final body = message.notification?.body ?? '';

    final data = message.data;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      0,
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
    // عرض الإشعار + تمرير البيانات عند الضغط عليه
  }

  // static void _onNotificationClick(String? payload) {
  //   if (payload == null || payload.isEmpty) return;

  //   try {
  //     final data = jsonDecode(payload);

  //     final template = data['template_label'] ?? '';
  //     final notificationId = data['notification_id']?.toString() ?? '';

  //     print("Template : $template");
  //     print("Notification ID : $notificationId");

  //     onTrackOpen?.call(notificationId);
  //     onNavigate?.call(template);
  //   } catch (e) {
  //     print("Notification parse error: $e");
  //   }
  // }
  static void _onNotificationClick(String? payload) {
    if (payload == null) return;

    final data = jsonDecode(payload);

    final notificationId = data['notification_id']?.toString();

    // print("Notification ID : $notificationId");

    if (notificationId != null) {
      onTrackOpen?.call(notificationId);
    }

    onNavigate?.call("notifications");
  }
}
