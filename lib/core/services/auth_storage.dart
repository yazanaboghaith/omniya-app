import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> saveToken(String? token) async {
    if (token == null || token.isEmpty) {
      await storage.delete(key: "token");
      return;
    }

    await storage.write(key: "token", value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  Future<bool> hasToken() async {
    return (await getToken()) != null;
  }

  Future<void> saveRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await storage.delete(key: "refresh_token");
      // print("======> refresh_token is null → deleted <======");
      return;
    }

    // print("======> SAVE refresh_token => $token <======");
    await storage.write(key: "refresh_token", value: token);

    // final check = await storage.read(key: "refresh_token");
    // print("======> VERIFY refresh_token => $check <======");
  }

  Future<String?> getRefreshToken() async {
    final value = await storage.read(key: "refresh_token");
    // print("======> GET refresh_token => $value <======");
    return value;
  }

  Future<void> saveUsername(String username) async {
    await storage.write(
      key: "username",
      value: username,
    );
  }

  Future<String?> getUsername() async {
    return await storage.read(
      key: "username",
    );
  }

  Future<void> saveBiometric(String value) async {
    await storage.write(key: "biometric", value: value);
  }

  Future<String?> getBiometric() async {
    return await storage.read(key: "biometric");
  }

  Future<void> savePin(String pin) async {
    await storage.write(key: "pin", value: pin);
  }

  Future<String?> getPin() async {
    return await storage.read(key: "pin");
  }

  Future<void> saveSecurityType(String type) async {
    await storage.write(key: "security_type", value: type);
  }

  Future<String?> getSecurityType() async {
    return await storage.read(key: "security_type");
  }

  Future<void> logout({String? reason}) async {
    // print("======> LOGOUT START <======");
    if (reason != null) {
      // print("======> Reason: $reason <======");
    }

    try {
      await clearAuthData();
      // print("======> Auth data cleared successfully <======");
    } catch (e) {
      debugPrint("======> ERROR while clearing auth: $e <======");
    }

    // print("======> LOGOUT END <======");
  }

  Future<void> clearAuthData() async {
    debugPrint('[AuthStorage] CLEAR AUTH DATA START');

    await storage.delete(key: "token");
    await storage.delete(key: "refresh_token");
    await storage.delete(key: "token_expiry");

    await storage.delete(key: "pin");
    await storage.delete(key: "biometric");
    await storage.delete(key: "security_type");
    await storage.delete(key: "last_username");
    await storage.delete(key: "username");

    debugPrint('[AuthStorage] CLEAR AUTH DATA DONE');
  }
}
