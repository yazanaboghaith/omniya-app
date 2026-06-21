import 'package:omniya/view/auth/services/auth_storage.dart';

class AppSecurityService {
  static final AuthStorage _storage = AuthStorage();

  static Future<bool> needsSecurity() async {
    final type = await _storage.getSecurityType();
    return type != null && type != "none";
  }

  static Future<String?> getSecurityType() async {
    return await _storage.getSecurityType();
  }
}
