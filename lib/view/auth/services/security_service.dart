import 'package:local_auth/local_auth.dart';
import 'package:omniya/view/auth/services/auth_storage.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();
  final AuthStorage _storage = AuthStorage();

  // جلب نوع الحماية المحفوظ مسبقاً (bio أو pin)
  Future<String?> getSecurityType() async {
    return await _storage.storage.read(key: "security_type");
  }

  // تفعيل وحفظ نوع الحماية في التخزين المحلي
  Future<void> setSecurityType(String type) async {
    await _storage.storage.write(key: "security_type", value: type);
  }

  // التحقق الفعلي من البصمة
  Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // التحقق من رمز PIN
  Future<bool> verifyPin(String enteredPin) async {
    final savedPin = await _storage.storage.read(key: "pin");
    return savedPin != null && savedPin == enteredPin;
  }

// حذف إعدادات الحماية بالكامل من التخزين المحلي
  Future<void> clearSecurityData() async {
    await _storage.storage.delete(key: "security_type");
    await _storage.storage.delete(key: "pin");
  }

  // إعداد وحفظ رمز PIN جديد
  Future<void> savePin(String pin) async {
    await _storage.storage.write(key: "pin", value: pin);
    await setSecurityType("pin");
  }
}
