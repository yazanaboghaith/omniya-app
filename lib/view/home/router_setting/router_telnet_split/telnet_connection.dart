import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'telnet_constants.dart';
import 'telnet_output_utils.dart';
import 'telnet_protocol.dart';
import 'telnet_prompt_detector.dart';

class TelnetConnection {
  Socket? _socket;
  StreamSubscription<List<int>>? _subscription;

  final StreamController<String> _outputController =
      StreamController<String>.broadcast();

  Stream<String> get outputStream => _outputController.stream;

  String _buffer = '';
  bool _disposed = false;
  Timer? _idleTimer;

  late final TelnetProtocol _protocol;

  TelnetConnection() {
    _protocol = TelnetProtocol(_sendRaw);
  }

  bool get isConnected => _socket != null;

  String get currentBuffer => _buffer;

  Future<void> connect({
    required String host,
    required int port,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_disposed) {
      throw StateError(
        'TelnetConnection has already been disposed.',
      );
    }

    if (isConnected) {
      debugPrint(
        '[Telnet][Connection] Already connected. Skipping connect.',
      );
      return;
    }

    debugPrint(
      '[Telnet][Connection] Opening connection to $host:$port ...',
    );

    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: timeout,
      );

      _socket = socket;
      _buffer = '';
      _protocol.clearPendingBytes();

      debugPrint(
        '[Telnet][Connection] Connection opened successfully.',
      );

      _subscription = socket.listen(
        _handleIncomingData,
        onError: (
          Object error,
          StackTrace stackTrace,
        ) {
          debugPrint(
            '[Telnet][Connection] Socket error: $error',
          );

          if (!_outputController.isClosed) {
            _outputController.addError(
              error,
              stackTrace,
            );
          }
        },
        onDone: () {
          debugPrint(
            '[Telnet][Connection] Remote socket closed the connection.',
          );

          _socket = null;
          _idleTimer?.cancel();
          _idleTimer = null;
        },
        cancelOnError: false,
      );

      _resetIdleTimer();

      await Future.delayed(
        const Duration(milliseconds: 150),
      );

      debugPrint(
        '[Telnet][Connection] Connection is ready.',
      );
    } catch (e) {
      debugPrint(
        '[Telnet][Connection]  Connection failed: $e',
      );
      rethrow;
    }
  }

  void _handleIncomingData(List<int> data) {
    if (_disposed || data.isEmpty) {
      return;
    }

    final bytes = List<int>.from(data);

    final cleanedBytes = _protocol.processBytes(bytes);

    if (cleanedBytes.isEmpty) {
      return;
    }

    final text = latin1.decode(
      cleanedBytes,
      allowInvalid: true,
    );

    _buffer += text;

    if (_buffer.length > 200000) {
      _buffer = _buffer.substring(
        _buffer.length - 100000,
      );
    }

    if (!_outputController.isClosed) {
      _outputController.add(text);
    }
  }

  void _sendRaw(List<int> bytes) {
    final socket = _socket;

    if (socket == null) {
      throw StateError(
        'Telnet connection is not established.',
      );
    }

    socket.add(bytes);
  }

  Future<void> send(
    String command, {
    bool enter = true,
  }) async {
    final socket = _socket;

    if (socket == null) {
      debugPrint(
        '[Telnet][Connection]  Cannot send command: not connected.',
      );

      throw StateError(
        'Telnet connection is not established.',
      );
    }

    final value = enter ? '$command\r\n' : command;

    debugPrint(
      '[Telnet][Connection] Sending: '
      '${TelnetOutputUtils.hideSensitiveCommand(command)}',
    );

    try {
      socket.add(
        latin1.encode(value),
      );

      await socket.flush();

      _resetIdleTimer();

      await Future.delayed(
        const Duration(milliseconds: 80),
      );

      debugPrint(
        '[Telnet][Connection] Command sent successfully.',
      );
    } catch (e) {
      debugPrint(
        '[Telnet][Connection]  Failed to send command: $e',
      );
      rethrow;
    }
  }

  void clearBuffer() {
    _buffer = '';
  }

  Future<String> waitForLoginToken({
    Duration timeout = TelnetConstants.loginTimeout,
  }) async {
    final start = DateTime.now();

    while (DateTime.now().difference(start) < timeout) {
      if (_buffer.isNotEmpty) {
        final clean = TelnetOutputUtils.clean(_buffer);

        if (clean.isNotEmpty) {
          return clean;
        }
      }

      await Future.delayed(
        TelnetConstants.pollDelay,
      );
    }

    return '';
  }

  Future<String> waitForText({
    required List<String> patterns,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final start = DateTime.now();

    while (DateTime.now().difference(start) < timeout) {
      if (_buffer.isNotEmpty) {
        final cleaned = TelnetOutputUtils.clean(_buffer);
        final lower = cleaned.toLowerCase();

        for (final pattern in patterns) {
          if (lower.contains(pattern.toLowerCase())) {
            final result = _buffer;
            _buffer = '';

            debugPrint(
              '[Telnet][Connection] Expected text detected: $pattern',
            );

            return result;
          }
        }
      }

      await Future.delayed(
        TelnetConstants.pollDelay,
      );
    }

    debugPrint(
      '[Telnet][Connection]  waitForText timeout.',
    );

    return '';
  }

  Future<String> waitForOutput({
    Duration timeout = const Duration(seconds: 10),
    Duration settleTime = const Duration(milliseconds: 300),
  }) async {
    final start = DateTime.now();

    while (DateTime.now().difference(start) < timeout) {
      if (_buffer.isNotEmpty) {
        break;
      }

      await Future.delayed(
        TelnetConstants.pollDelay,
      );
    }

    if (_buffer.isEmpty) {
      debugPrint(
        '[Telnet][Connection]  No output received before timeout.',
      );
      return '';
    }

    var lastLength = _buffer.length;

    while (DateTime.now().difference(start) < timeout) {
      await Future.delayed(
        TelnetConstants.packetDelay,
      );

      if (_buffer.length != lastLength) {
        lastLength = _buffer.length;
        continue;
      }

      await Future.delayed(
        settleTime,
      );

      if (_buffer.length == lastLength) {
        final result = _buffer;
        _buffer = '';

        debugPrint(
          '[Telnet][Connection] Output received and settled.',
        );

        return result;
      }

      lastLength = _buffer.length;
    }

    final result = _buffer;
    _buffer = '';

    debugPrint(
      '[Telnet][Connection]  waitForOutput timeout. Returning current buffer.',
    );

    return result;
  }

  Future<String> waitForPrompt({
    Duration timeout = const Duration(seconds: 10),
    String? prompt,
  }) async {
    final start = DateTime.now();

    while (DateTime.now().difference(start) < timeout) {
      if (_buffer.isEmpty) {
        await Future.delayed(
          TelnetConstants.pollDelay,
        );
        continue;
      }

      final cleaned = TelnetOutputUtils.clean(_buffer);

      if (cleaned.isEmpty) {
        await Future.delayed(
          TelnetConstants.pollDelay,
        );
        continue;
      }

      if (prompt != null && cleaned.contains(prompt)) {
        final result = _buffer;
        _buffer = '';

        debugPrint(
          '[Telnet][Connection] Requested prompt detected: $prompt',
        );

        return result;
      }

      if (TelnetPromptDetector.hasPrompt(cleaned)) {
        await Future.delayed(
          TelnetConstants.promptSettleTime,
        );

        final result = _buffer;
        _buffer = '';

        debugPrint(
          '[Telnet][Connection] Router prompt detected.',
        );

        return result;
      }

      await Future.delayed(
        TelnetConstants.pollDelay,
      );
    }

    if (_buffer.isNotEmpty) {
      final result = _buffer;
      _buffer = '';

      debugPrint(
        '[Telnet][Connection]  Prompt timeout. Returning current buffer.',
      );

      return result;
    }

    debugPrint(
      '[Telnet][Connection]  Prompt timeout with empty buffer.',
    );

    return '';
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();

    if (!isConnected || _disposed) {
      return;
    }

    _idleTimer = Timer(
      const Duration(minutes: 3),
      () async {
        debugPrint(
          '[Telnet][Connection] Idle timeout reached. Disconnecting...',
        );
        await disconnect();
      },
    );
  }

  Future<void> disconnect() async {
    debugPrint(
      '[Telnet][Connection] Closing connection...',
    );

    _idleTimer?.cancel();
    _idleTimer = null;

    final subscription = _subscription;
    final socket = _socket;

    _subscription = null;
    _socket = null;
    _buffer = '';

    _protocol.clearPendingBytes();

    try {
      await subscription?.cancel();
    } catch (e) {
      debugPrint(
        '[Telnet][Connection]  Failed to cancel subscription: $e',
      );
    }

    try {
      await socket?.flush();
    } catch (e) {
      debugPrint(
        '[Telnet][Connection]  Failed to flush socket: $e',
      );
    }

    try {
      await socket?.close();
    } catch (e) {
      debugPrint(
        '[Telnet][Connection]  Failed to close socket: $e',
      );
    }

    debugPrint(
      '[Telnet][Connection] Connection closed.',
    );
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    debugPrint(
      '[Telnet][Connection] Disposing connection service...',
    );

    _disposed = true;

    _idleTimer?.cancel();
    _idleTimer = null;

    await disconnect();

    if (!_outputController.isClosed) {
      await _outputController.close();
    }

    debugPrint(
      '[Telnet][Connection] Connection service disposed.',
    );
  }
}
