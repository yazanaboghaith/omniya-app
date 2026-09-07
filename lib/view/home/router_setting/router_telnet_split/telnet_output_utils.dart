class TelnetOutputUtils {
  static String clean(String text) {
    var result = text;

    result = result.replaceAll(
      RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'),
      '',
    );

    result = result.replaceAll(
      RegExp(r'\x1B\][^\x07]*(?:\x07|\x1B\\)'),
      '',
    );

    result = result.replaceAll('\r\n', '\n');
    result = result.replaceAll('\r', '\n');
    result = result.replaceAll('\x00', '');
    result = result.replaceAll('\b', '');
    result = result.replaceAll('\t', ' ');

    result = result.replaceAll(
      RegExp(r'[\x01-\x08\x0B\x0C\x0E-\x1F]'),
      '',
    );

    result = result.replaceAll(
      RegExp(r'\n{3,}'),
      '\n\n',
    );

    return result.trim();
  }

  static String hideSensitiveCommand(String command) {
    final tpLinkRegex = RegExp(
      r'(wlctl\s+set\s+(?:2g|5g)\s+--sec\s+psk\s+wpa2\s+aes\s+)(.+)$',
      caseSensitive: false,
    );

    final tpLinkMatch = tpLinkRegex.firstMatch(command);
    if (tpLinkMatch != null) {
      return '${tpLinkMatch.group(1)}********';
    }

    final passphaseRegex = RegExp(
      r'(passphase\s+)(.+)$',
      caseSensitive: false,
    );

    final passphaseMatch = passphaseRegex.firstMatch(command);
    if (passphaseMatch != null) {
      return '${passphaseMatch.group(1)}********';
    }

    final passwordRegex = RegExp(
      r'(password\s*[=:]\s*)(.+)$',
      caseSensitive: false,
    );

    final passwordMatch = passwordRegex.firstMatch(command);
    if (passwordMatch != null) {
      return '${passwordMatch.group(1)}********';
    }

    final pskRegex = RegExp(
      r'(psk\s*[=:]\s*)(.+)$',
      caseSensitive: false,
    );

    final pskMatch = pskRegex.firstMatch(command);
    if (pskMatch != null) {
      return '${pskMatch.group(1)}********';
    }

    return command;
  }
}
