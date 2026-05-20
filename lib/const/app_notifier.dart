import 'dart:async';
import 'package:flutter/material.dart';
import 'package:omniya/const/app_color.dart';

enum NotifyType { success, error }

class AppNotifier {
  static final AppNotifier instance = AppNotifier._internal();
  AppNotifier._internal();

  OverlayEntry? _entry;

  void show({
    required BuildContext context,
    required String message,
    required NotifyType type,
    int seconds = 2,
  }) {
    _entry?.remove();

    _entry = OverlayEntry(
      builder: (context) {
        return _NotifyWidget(message: message, type: type);
      },
    );

    Overlay.of(context).insert(_entry!);

    Timer(Duration(seconds: seconds), () {
      _entry?.remove();
      _entry = null;
    });
  }

  void success(BuildContext context, String msg) {
    show(context: context, message: msg, type: NotifyType.success);
  }

  void error(BuildContext context, String msg) {
    show(context: context, message: msg, type: NotifyType.error);
  }
}

//////////////////////////
/////////////////////////
//////////////////////////
/////////////////////////
/////////////////////////

class _NotifyWidget extends StatelessWidget {
  final String message;
  final NotifyType type;

  const _NotifyWidget({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final isSuccess = type == NotifyType.success;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 260,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.text(context).withValues(alpha: 0.15),
              width: 1,
            ),
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
////AppNotifier.instance.error(context, result.message);
///AppNotifier.instance.success(context, "تم تسجيل الدخول بنجاح");
///AppNotifier.instance.error(context, "كلمة المرور غير صحيحة");