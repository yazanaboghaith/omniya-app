import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:omniya/core/const/app_color.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

class App403Notifier {
  static final App403Notifier instance = App403Notifier._internal();

  App403Notifier._internal();

  OverlayEntry? _entry;
  bool _isEntryInserted = false;

  // ============================================================
  // REMOVE CURRENT NOTIFICATION
  // ============================================================

  void _removeEntry() {
    final entry = _entry;

    if (entry == null) {
      debugPrint(
        '[App403Notifier] No notification to remove.',
      );
      return;
    }

    debugPrint(
      '[App403Notifier] Removing notification...',
    );

    try {
      if (_isEntryInserted) {
        entry.remove();

        debugPrint(
          '[App403Notifier] Notification removed successfully.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        '[App403Notifier] ERROR while removing OverlayEntry: $e',
      );

      debugPrint(
        '[App403Notifier] STACK TRACE: $stackTrace',
      );
    } finally {
      if (identical(_entry, entry)) {
        _entry = null;
        _isEntryInserted = false;
      }
    }
  }

  // ============================================================
  // SHOW NOTIFICATION
  // ============================================================

  void show({
    required BuildContext context,
    required String message,
    String? link,
    String? title,
    String? buttonText,
    VoidCallback? onButtonPressed,
    int seconds = 0,
  }) {
    debugPrint(
      '[App403Notifier] ========================================',
    );

    debugPrint(
      '[App403Notifier] SHOW 426 NOTIFICATION',
    );

    debugPrint(
      '[App403Notifier] MESSAGE => $message',
    );

    debugPrint(
      '[App403Notifier] LINK => $link',
    );

    debugPrint(
      '[App403Notifier] ========================================',
    );

    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      debugPrint(
        '[App403Notifier] ERROR: AppLocalizations is null.',
      );

      return;
    }

    // إزالة أي إشعار سابق
    _removeEntry();

    final overlay = Overlay.maybeOf(
      context,
      rootOverlay: true,
    );

    if (overlay == null) {
      debugPrint(
        '[App403Notifier] ERROR: Overlay is null.',
      );

      return;
    }

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _Error403Widget(
          title: title ?? l10n.error,
          message: message,
          link: link,
          buttonText: buttonText ?? l10n.update_now,
          onButtonPressed: onButtonPressed,
          onClose: () {
            if (identical(_entry, entry)) {
              _removeEntry();
            }
          },
        );
      },
    );

    _entry = entry;
    _isEntryInserted = false;

    try {
      overlay.insert(entry);

      _isEntryInserted = true;

      debugPrint(
        '[App403Notifier] Notification inserted successfully.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[App403Notifier] ERROR while inserting notification: $e',
      );

      debugPrint(
        '[App403Notifier] STACK TRACE: $stackTrace',
      );

      if (identical(_entry, entry)) {
        _entry = null;
        _isEntryInserted = false;
      }

      return;
    }
    if (seconds > 0) {
      Timer(
        Duration(seconds: seconds),
        () {
          if (identical(_entry, entry)) {
            _removeEntry();
          }
        },
      );
    }
  }
}

class _Error403Widget extends StatelessWidget {
  final String title;
  final String message;
  final String? link;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final VoidCallback onClose;

  const _Error403Widget({
    required this.title,
    required this.message,
    required this.link,
    required this.buttonText,
    required this.onButtonPressed,
    required this.onClose,
  });

  Future<void> _openUpdateUrl(
    String url,
  ) async {
    debugPrint(
      '[426 DIALOG] UPDATE BUTTON PRESSED',
    );

    debugPrint(
      '[426 DIALOG] URL => $url',
    );

    final cleanUrl = url.trim();

    if (cleanUrl.isEmpty) {
      debugPrint(
        '[426 DIALOG] URL IS EMPTY',
      );

      return;
    }

    final Uri? uri = Uri.tryParse(cleanUrl);

    if (uri == null) {
      debugPrint(
        '[426 DIALOG] INVALID URL => $cleanUrl',
      );

      return;
    }

    debugPrint(
      '[426 DIALOG] PARSED URI => $uri',
    );

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      debugPrint(
        '[426 DIALOG] EXTERNAL LAUNCH RESULT => $launched',
      );

      if (launched) {
        debugPrint(
          '[426 DIALOG] UPDATE URL OPENED SUCCESSFULLY',
        );

        return;
      }

      debugPrint(
        '[426 DIALOG] EXTERNAL APPLICATION FAILED',
      );

      final bool fallbackLaunched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      debugPrint(
        '[426 DIALOG] FALLBACK LAUNCH RESULT => $fallbackLaunched',
      );

      if (fallbackLaunched) {
        debugPrint(
          '[426 DIALOG] FALLBACK URL OPENED SUCCESSFULLY',
        );
      } else {
        debugPrint(
          '[426 DIALOG] CANNOT OPEN UPDATE URL',
        );
      }

      debugPrint(
        '[426 DIALOG] ========================================',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[426 DIALOG] URL LAUNCH ERROR => $e',
      );

      debugPrint(
        '[426 DIALOG] STACK TRACE => $stackTrace',
      );
    }
  }

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
                  color: Colors.white.withValues(
                    alpha: 0.2,
                  ),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      title,
                      style: AppTextStyles.text17Bold(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.text15(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryText,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                      onPressed: () async {
                        debugPrint(
                          '[426 DIALOG] UPDATE NOW BUTTON PRESSED',
                        );

                        // ==================================================
                        // إذا كان السيرفر أرسل رابط التحديث
                        // ==================================================

                        if (link != null && link!.trim().isNotEmpty) {
                          await _openUpdateUrl(
                            link!,
                          );
                        } else {
                          debugPrint(
                            '[426 DIALOG] NO UPDATE LINK PROVIDED',
                          );
                        }

                        // ==================================================
                        // Callback اختياري
                        // ==================================================

                        onButtonPressed?.call();

                        // ==================================================
                        // إغلاق الإشعار
                        // ==================================================

                        onClose();
                      },
                      child: Text(
                        buttonText,
                        style: AppTextStyles.text15(
                          context,
                        ).copyWith(
                          color: Colors.white,
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
