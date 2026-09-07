import 'package:flutter/foundation.dart';

import 'telnet_constants.dart';

class TelnetProtocol {
  final void Function(List<int> bytes) _sendRaw;

  final List<int> _pendingBytes = <int>[];

  TelnetProtocol(this._sendRaw);

  List<int> processBytes(List<int> input) {
    final bytes = <int>[
      ..._pendingBytes,
      ...input,
    ];

    _pendingBytes.clear();

    final output = <int>[];
    int i = 0;

    while (i < bytes.length) {
      final byte = bytes[i];

      if (byte != TelnetConstants.iac) {
        output.add(byte);
        i++;
        continue;
      }

      if (i + 1 >= bytes.length) {
        _pendingBytes.add(bytes[i]);
        break;
      }

      final command = bytes[i + 1];

      if (command == TelnetConstants.iac) {
        output.add(TelnetConstants.iac);
        i += 2;
        continue;
      }

      if (command == TelnetConstants.will ||
          command == TelnetConstants.wont ||
          command == TelnetConstants.doCommand ||
          command == TelnetConstants.dont) {
        if (i + 2 >= bytes.length) {
          _pendingBytes.addAll(bytes.sublist(i));
          break;
        }

        final option = bytes[i + 2];

        debugPrint(
          '[Telnet][Protocol] Negotiation: '
          '${_debugCommand(command)} option=$option',
        );

        _handleNegotiation(command, option);

        i += 3;
        continue;
      }

      if (command == TelnetConstants.sb) {
        int endIndex = -1;

        for (int j = i + 2; j < bytes.length - 1; j++) {
          if (bytes[j] == TelnetConstants.iac &&
              bytes[j + 1] == TelnetConstants.se) {
            endIndex = j;
            break;
          }
        }

        if (endIndex == -1) {
          _pendingBytes.addAll(bytes.sublist(i));
          break;
        }

        i = endIndex + 2;
        continue;
      }

      i += 2;
    }

    return output;
  }

  void clearPendingBytes() {
    _pendingBytes.clear();
  }

  void _handleNegotiation(
    int command,
    int option,
  ) {
    if (command == TelnetConstants.will) {
      if (option == TelnetConstants.echo ||
          option == TelnetConstants.suppressGoAhead) {
        _sendTelnet(
          TelnetConstants.dont,
          option,
        );
        return;
      }

      _sendTelnet(
        TelnetConstants.dont,
        option,
      );
      return;
    }

    if (command == TelnetConstants.wont) {
      return;
    }

    if (command == TelnetConstants.doCommand) {
      if (option == TelnetConstants.binary) {
        _sendTelnet(
          TelnetConstants.wont,
          option,
        );
        return;
      }

      _sendTelnet(
        TelnetConstants.wont,
        option,
      );
      return;
    }

    if (command == TelnetConstants.dont) {
      return;
    }
  }

  void _sendTelnet(
    int command,
    int option,
  ) {
    try {
      _sendRaw(<int>[
        TelnetConstants.iac,
        command,
        option,
      ]);

      debugPrint(
        '[Telnet][Protocol] Sent negotiation: '
        '${_debugCommand(command)} option=$option',
      );
    } catch (e) {
      debugPrint(
        '[Telnet][Protocol] Failed to send negotiation: $e',
      );
    }
  }

  String _debugCommand(int command) {
    switch (command) {
      case TelnetConstants.will:
        return 'WILL';
      case TelnetConstants.wont:
        return 'WONT';
      case TelnetConstants.doCommand:
        return 'DO';
      case TelnetConstants.dont:
        return 'DONT';
      default:
        return 'UNKNOWN($command)';
    }
  }

  String debugBytes(List<int> bytes) {
    final result = StringBuffer();

    for (final byte in bytes) {
      switch (byte) {
        case TelnetConstants.iac:
          result.write('IAC ');
          break;
        case TelnetConstants.will:
          result.write('WILL ');
          break;
        case TelnetConstants.wont:
          result.write('WONT ');
          break;
        case TelnetConstants.doCommand:
          result.write('DO ');
          break;
        case TelnetConstants.dont:
          result.write('DONT ');
          break;
        case TelnetConstants.sb:
          result.write('SB ');
          break;
        case TelnetConstants.se:
          result.write('SE ');
          break;
        case 13:
          result.write(r'\r ');
          break;
        case 10:
          result.write(r'\n ');
          break;
        case 0:
          result.write(r'\0 ');
          break;
        default:
          if (byte >= 32 && byte <= 126) {
            result.write('${String.fromCharCode(byte)} ');
          } else {
            result.write('<$byte> ');
          }
      }
    }

    return result.toString().trim();
  }
}
