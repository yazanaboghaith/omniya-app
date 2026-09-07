enum TelnetErrorType {
  invalidCredentials,
  gatewayNotFound,
  noInternet,
  telnetUnavailable,
  connectionRefused,
  connectionTimeout,
  networkUnreachable,
  hostUnreachable,
  hostLookupFailed,
  unknown,
}

class TelnetLoginException implements Exception {
  final TelnetErrorType type;
  final String? rawMessage;

  const TelnetLoginException(
    this.type, {
    this.rawMessage,
  });

  @override
  String toString() {
    return rawMessage ?? type.name;
  }
}
