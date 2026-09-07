import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:omniya/core/services/auth_storage.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();
  final AuthStorage _storage = AuthStorage();

  // ============================================================
  // SECURITY TYPE
  // ============================================================

  Future<String?> getSecurityType() async {
    return await _storage.storage.read(
      key: "security_type",
    );
  }

  Future<void> setSecurityType(String type) async {
    await _storage.storage.write(
      key: "security_type",
      value: type,
    );
  }

  // ============================================================
  // DELETE SECURITY DATA
  // ============================================================

  Future<void> clearSecurityData() async {
    await _storage.storage.delete(
      key: "security_type",
    );

    await _storage.storage.delete(
      key: "pin",
    );
  }

  // ============================================================
  // DELETE LOGIN SESSION
  // ============================================================

  Future<void> clearLoginSession() async {
    debugPrint(
      "========== CLEAR LOGIN SESSION ==========",
    );

    await _storage.storage.delete(
      key: "token",
    );

    await _storage.storage.delete(
      key: "refresh_token",
    );

    await _storage.storage.delete(
      key: "token_expiry",
    );

    await _storage.storage.delete(
      key: "last_username",
    );

    debugPrint(
      "LOGIN SESSION CLEARED",
    );
  }

  // ============================================================
  // BIOMETRIC
  // ============================================================

  Future<bool> authenticateWithBiometrics(
    String reason,
  ) async {
    try {
      debugPrint(
        "========== BIOMETRIC AUTH START ==========",
      );

      final supported = await _auth.isDeviceSupported();

      debugPrint(
        "isDeviceSupported => $supported",
      );

      if (!supported) {
        debugPrint(
          "Device does not support biometric authentication",
        );

        return false;
      }

      final canCheck = await _auth.canCheckBiometrics;

      debugPrint(
        "canCheckBiometrics => $canCheck",
      );

      if (!canCheck) {
        debugPrint(
          "Cannot check biometrics",
        );

        return false;
      }

      final available = await _auth.getAvailableBiometrics();

      debugPrint(
        "availableBiometrics => $available",
      );

      if (available.isEmpty) {
        debugPrint(
          "No biometric enrolled",
        );

        return false;
      }

      debugPrint(
        "Opening biometric authentication...",
      );

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      debugPrint(
        "BIOMETRIC RESULT => $authenticated",
      );

      return authenticated;
    } catch (e, stackTrace) {
      debugPrint(
        "BIOMETRIC ERROR => $e",
      );

      debugPrint(
        "STACK => $stackTrace",
      );

      return false;
    }
  }

  // ============================================================
  // PIN
  // ============================================================

  Future<void> savePin(String pin) async {
    await _storage.storage.write(
      key: "pin",
      value: pin,
    );

    await setSecurityType("pin");
  }

  Future<bool> verifyPin(String enteredPin) async {
    final savedPin = await _storage.storage.read(
      key: "pin",
    );

    if (savedPin == null) {
      return false;
    }

    return savedPin == enteredPin;
  }
}
