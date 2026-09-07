import 'package:flutter/material.dart';
import 'package:omniya/core/l10n/app_localizations.dart';

class ApiErrorHandler {
  static String getUnhandledErrorMessage({
    required BuildContext context,
  }) {
    return AppLocalizations.of(context)!.server_Error;
  }
}
