import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omniya/core/const/app_notifier.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/model/notification_model.dart';
import 'package:omniya/core/services/api_client.dart';

enum NotificationState {
  idle,
  loading,
  success,
  serverError,
  error,
  unauthorized,
}

class NotificationsController with ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  bool isLoadingNotification = false;

  NotificationState state = NotificationState.idle;

  String? error;

  final String apiGetNotification = "${AppApi.url}${AppApi.getnotifications}";
  final String apitrackopen = "${AppApi.url}${AppApi.trackopen}";
  List<NotificationItem> notifications = [];

  Future<void> getNotifications({
    BuildContext? context,
    String type = "all",
    bool refresh = false,
  }) async {
    debugPrint("========== GET NOTIFICATIONS ==========");
    if (!refresh) {
      isLoadingNotification = true;
      notifyListeners();
    }

    isLoadingNotification = true;
    state = NotificationState.loading;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        "$apiGetNotification?type=$type",
      );

      debugPrint("URL : $uri");
      debugPrint("TYPE : $type");

      final response = await apiClient.get(uri);

      debugPrint("STATUS CODE : ${response.statusCode}");
      debugPrint("RESPONSE : ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final notificationModel = NotificationModel.fromJson(jsonData);

        notifications = notificationModel.data;

        debugPrint(
          "تم جلب ${notifications.length} إشعار بنجاح",
        );

        state = NotificationState.success;
      } else {
        error = "Server error: ${response.statusCode}";
        state = NotificationState.serverError;

        debugPrint(
          "فشل في جلب الإشعارات : ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("ERROR GET NOTIFICATIONS : $e");

      if (e.toString().contains("SESSION_EXPIRED")) {
        error = "Unauthorized - يرجى تسجيل الدخول مرة أخرى";
        state = NotificationState.unauthorized;

        if (context != null && context.mounted) {
          AppNotifier.instance
              .error(context, "خطا في الاتصال, يرجى, إعادة المحاولة");
        }
      } else {
        error = e.toString();
        state = NotificationState.error;
      }
    } finally {
      isLoadingNotification = false;
      notifyListeners();

      debugPrint("========== END GET NOTIFICATIONS ==========");
    }
  }

////////////////////////////////////
////////////////////////////////////
////////////////////////////////////
////////////////////////////////////
  Future<bool> trackOpen(String notificationId) async {
    try {
      debugPrint("========== TRACK OPEN START ==========");
      debugPrint("Notification ID: $notificationId");

      if (notificationId.isEmpty) {
        debugPrint(" ERROR: notificationId is empty");
        return false;
      }
      debugPrint("FINAL URL => $apitrackopen");
      final url = Uri.parse(apitrackopen);

      debugPrint("Request URL: $url");

      final body = {
        "notification_id": int.parse(notificationId),
      };

      debugPrint(" Request Body: $body");

      final response = await apiClient.post(url, body);

      debugPrint(" Response Status Code: ${response.statusCode}");
      debugPrint(" Response Body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint(" TRACK OPEN SUCCESS");
        debugPrint("========== TRACK OPEN END ==========");
        return true;
      } else {
        debugPrint(" TRACK OPEN FAILED");
        debugPrint("Status is not 200");
        debugPrint("========== TRACK OPEN END ==========");
        return false;
      }
    } catch (e, stack) {
      debugPrint(" TRACK OPEN ERROR: $e");
      debugPrint("STACK TRACE: $stack");
      debugPrint("========== TRACK OPEN END ==========");
      return false;
    }
  }
}
