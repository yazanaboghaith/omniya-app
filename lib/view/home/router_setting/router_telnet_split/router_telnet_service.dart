import 'package:flutter/foundation.dart';

import 'telnet_command_service.dart';
import 'telnet_connection.dart';
import 'telnet_login_service.dart';
import 'telnet_wifi_service.dart';

class RouterTelnetService {
  late final TelnetConnection _connection;
  late final TelnetLoginService _login;
  late final TelnetCommandService _commands;
  late final TelnetWifiService _wifi;

  RouterTelnetService() {
    _connection = TelnetConnection();

    _login = TelnetLoginService(
      _connection,
    );

    _commands = TelnetCommandService(
      connection: _connection,
      loginService: _login,
    );

    _wifi = TelnetWifiService(
      connection: _connection,
      commands: _commands,
    );

    debugPrint(
      '[Telnet] RouterTelnetService initialized.',
    );
  }

  bool get isConnected => _connection.isConnected;

  Stream<String> get outputStream =>
      _connection.outputStream;

  String get currentBuffer =>
      _connection.currentBuffer;

  Future<void> connect({
    required String host,
    required int port,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    debugPrint(
      '[Telnet] Opening router connection...',
    );

    await _connection.connect(
      host: host,
      port: port,
      timeout: timeout,
    );
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    debugPrint(
      '[Telnet] Starting router login...',
    );

    await _login.login(
      username: username,
      password: password,
    );
  }

  Future<String> execute(
    String command, {
    Duration timeout = const Duration(seconds: 15),
    bool waitForPrompt = true,
  }) {
    return _commands.execute(
      command,
      timeout: timeout,
      waitForPrompt: waitForPrompt,
    );
  }

  Future<String> getLineStatistics(
    String command, {
    Duration timeout = const Duration(seconds: 15),
  }) {
    return _commands.getLineStatistics(
      command,
      timeout: timeout,
    );
  }

  Future<String> changeWifiPassword(
    String command, {
    Duration timeout = const Duration(seconds: 15),
    String? restartCommand,
  }) {
    return _wifi.changeWifiPassword(
      command,
      timeout: timeout,
      restartCommand: restartCommand,
    );
  }

  Future<String> waitForText({
    required List<String> patterns,
    Duration timeout = const Duration(seconds: 8),
  }) {
    return _connection.waitForText(
      patterns: patterns,
      timeout: timeout,
    );
  }

  Future<String> waitForOutput({
    Duration timeout = const Duration(seconds: 10),
    Duration settleTime = const Duration(milliseconds: 300),
  }) {
    return _connection.waitForOutput(
      timeout: timeout,
      settleTime: settleTime,
    );
  }

  Future<String> waitForPrompt({
    Duration timeout = const Duration(seconds: 10),
    String? prompt,
  }) {
    return _connection.waitForPrompt(
      timeout: timeout,
      prompt: prompt,
    );
  }

  Future<void> send(
    String command, {
    bool enter = true,
  }) {
    return _connection.send(
      command,
      enter: enter,
    );
  }

  void clearBuffer() {
    _connection.clearBuffer();
  }

  Future<void> disconnect() async {
    debugPrint(
      '[Telnet] Disconnect requested.',
    );

    await _connection.disconnect();
  }

  Future<void> dispose() async {
    debugPrint(
      '[Telnet] Disposing RouterTelnetService...',
    );

    await _connection.dispose();
  }
}
