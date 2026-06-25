import 'dart:async';
import 'auth_service.dart';

class TokenRefreshWorker {
  final AuthService authService = AuthService();
  Timer? _timer;

  void start() {
    _timer = Timer.periodic(const Duration(hours: 12), (timer) async {
      await authService.refreshToken();
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
