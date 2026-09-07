import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

enum NotifyType { success, error }

class AppNotifier {
  static final AppNotifier instance = AppNotifier._internal();

  AppNotifier._internal();

  OverlayEntry? _entry;

  void show({
    required BuildContext context,
    String? title,
    required String message,
    required bool isSuccess,
    String? buttonText,
    VoidCallback? onButtonPressed,
    int seconds = 0,
  }) {
    _entry?.remove();

    final l10n = AppLocalizations.of(context)!;

    _entry = OverlayEntry(
      builder: (context) {
        return _NotifyWidget(
          title: title,
          message: message,
          isSuccess: isSuccess,
          buttonText: buttonText ?? l10n.confirm,
          onButtonPressed: onButtonPressed,
          onClose: () {
            _entry?.remove();
            _entry = null;
          },
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);

    if (seconds > 0) {
      Timer(
        Duration(seconds: seconds),
        () {
          _entry?.remove();
          _entry = null;
        },
      );
    }
  }

  void success(
    BuildContext context,
    String message,
  ) {
    final l10n = AppLocalizations.of(context)!;

    show(
      context: context,
      message: message,
      title: l10n.success,
      isSuccess: true,
    );
  }

  void error(
    BuildContext context,
    String message,
  ) {
    final l10n = AppLocalizations.of(context)!;

    show(
      context: context,
      message: message,
      title: l10n.error,
      isSuccess: false,
    );
  }

  void msg(
    BuildContext context,
    String message,
  ) {
    final l10n = AppLocalizations.of(context)!;

    show(
      context: context,
      message: message,
      title: l10n.error,
      isSuccess: false,
    );
  }
}

class _NotifyWidget extends StatelessWidget {
  final String? title;
  final String message;
  final bool isSuccess;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final VoidCallback onClose;

  const _NotifyWidget({
    this.title,
    required this.message,
    required this.isSuccess,
    required this.buttonText,
    required this.onButtonPressed,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black12,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 15,
              sigmaY: 15,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: AppTextStyles.text17Bold(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.text15(context),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white30,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        onButtonPressed?.call();
                        onClose();
                      },
                      child: Text(
                        buttonText,
                        style: AppTextStyles.text15(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
