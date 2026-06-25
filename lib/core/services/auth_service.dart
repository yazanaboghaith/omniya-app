import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';
import 'package:omniya/core/const/url.dart';

class AuthService {
  final AuthStorage storage = AuthStorage();
  final String refreshUrl = "${AppApi.url}${AppApi.refresh}";

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        // print(
        //   "======> [AuthService] لا يوجد Refresh Token في الـ Storage <======",
        // );
        return false;
      }

      // print(
      //   "======> [AuthService] إرسال الـ Refresh Token إلى السيرفر... <======",
      // );
      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"refresh_token": refreshToken}),
      );

      // print(
      //   "======> [AuthService] استجابة التحديث: ${response.statusCode} <======",
      // );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await storage.saveToken(data["token"]);
        await storage.saveRefreshToken(data["refresh_token"]);

        // print(
        //   "======> [AuthService] تم حفظ التوكنات الجديدة بنجاح في التخزين الآمن <======",
        // );
        return true;
      }

      return false;
    } catch (e) {
      // print("======> [AuthService] خطأ أثناء تحديث التوكن: $e <======");
      return false;
    }
  }

  Future<void> logout() async {
    // print(
    //   "======> [AuthService] جاري مسح كل بيانات الجلسة والحماية... <======",
    // );
    await storage.logout();
  }
}
