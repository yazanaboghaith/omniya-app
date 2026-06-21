import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceService {
  static Future<Map<String, dynamic>> getDeviceData() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String fcmToken = await FirebaseMessaging.instance.getToken() ?? "";

    String deviceType = Platform.isAndroid ? "android" : "ios";

    String deviceName = "";
    String deviceUuid = "";

    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await deviceInfo.androidInfo;

      deviceName = "${android.brand} ${android.model}";

      deviceUuid = android.id;
    }

    if (Platform.isIOS) {
      IosDeviceInfo ios = await deviceInfo.iosInfo;

      deviceName = "${ios.name} ${ios.model}";

      deviceUuid = ios.identifierForVendor ?? "";
    }

    return {
      "fcm_token": fcmToken,
      "device_type": deviceType,
      "device_name": deviceName,
      "device_uuid": deviceUuid,
    };
  }
}
