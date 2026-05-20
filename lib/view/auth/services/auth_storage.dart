import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await storage.write(key: "token", value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  Future<bool> hasToken() async {
    return (await getToken()) != null;
  }

  Future<void> saveRefreshToken(String token) async {
    await storage.write(key: "refresh_token", value: token);
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: "refresh_token");
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

  Future<void> logout() async {
    await storage.deleteAll();
  }
}
