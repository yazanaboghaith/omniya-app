import 'telnet_constants.dart';
import 'telnet_output_utils.dart';

class TelnetPromptDetector {
  static bool containsUsernamePrompt(String text) {
    final lower = text.toLowerCase();

    for (final pattern in TelnetConstants.usernamePatterns) {
      if (lower.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  static bool containsPasswordPrompt(String text) {
    final lower = text.toLowerCase();

    for (final pattern in TelnetConstants.passwordPatterns) {
      if (lower.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  static bool looksLikePasswordRequest(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return false;
    }

    final last = lines.last.toLowerCase();

    return last == 'password' ||
        last == 'passwd' ||
        last == 'pass';
  }

  static bool looksLikeUsernameRequest(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return false;
    }

    final last = lines.last.toLowerCase();

    return last == 'login' ||
        last == 'username' ||
        last == 'user';
  }

  static bool isLoginFailure(String text) {
    final lower = text.toLowerCase();

    for (final pattern in TelnetConstants.loginFailurePatterns) {
      if (lower.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  static bool hasPrompt(String text) {
    final cleaned = TelnetOutputUtils.clean(text);

    if (cleaned.isEmpty) {
      return false;
    }

    final lines = cleaned
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return false;
    }

    final last = lines.last.trim();

    if (last.isEmpty) {
      return false;
    }

    if (last == '#' ||
        last == '>' ||
        last == '\$' ||
        last == '%') {
      return true;
    }

    if (RegExp(
      r'^[^\r\n]{0,120}[#>%\$]$',
    ).hasMatch(last)) {
      return true;
    }

    final trimmed = last.trimRight();

    for (final character in TelnetConstants.promptCharacters) {
      if (trimmed.endsWith(character)) {
        return true;
      }
    }

    return false;
  }
}
