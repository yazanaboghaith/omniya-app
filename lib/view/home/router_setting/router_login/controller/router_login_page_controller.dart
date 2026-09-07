import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:omniya/core/const/url.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/core/services/auth_storage.dart';
import 'package:omniya/core/services/api_error_handler.dart';
import 'package:omniya/model/setting/router_commands_response.dart';
import 'package:omniya/view/home/router_setting/router_telnet_split/router_telnet_service.dart';

class RouterLoginPageController with ChangeNotifier {
  RouterLoginPageController({
    required this.routerId,
  });

  final int routerId;

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final RouterTelnetService telnetService = RouterTelnetService();

  final AuthStorage storage = AuthStorage();

  bool obscurePassword = true;

  bool isLoading = false;

  String status = '';

  String? errorMessage;

  String? subscriberUsername;

  String? connectionStatus;

  String? savedUsername;

  bool usernameChanged = false;

  bool passwordChanged = false;

  bool _serviceTransferred = false;

  String? _token;

  RouterCommandsResponse? _commandsResponse;

  RouterCommandsResponse? get commandsResponse => _commandsResponse;

  void transferTelnetService() {
    _serviceTransferred = true;
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  String? _getServerMessage(
    String responseBody,
  ) {
    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        if (decoded['error'] != null) {
          final message = decoded['error'].toString().trim();

          if (message.isNotEmpty) {
            return message;
          }
        }

        if (decoded['message'] != null) {
          final message = decoded['message'].toString().trim();

          if (message.isNotEmpty) {
            return message;
          }
        }

        if (decoded['msg'] != null) {
          final message = decoded['msg'].toString().trim();

          if (message.isNotEmpty) {
            return message;
          }
        }
      }
    } catch (e) {
      debugPrint(
        '[RouterLoginPageController] '
        'SERVER MESSAGE PARSE ERROR: $e',
      );
    }

    return null;
  }

  String _getUserFriendlyConnectionError(
    Object error,
    AppLocalizations l10n,
  ) {
    final message = error.toString().toLowerCase();

    debugPrint(
      '[RouterLoginPageController] '
      'RAW CONNECTION ERROR: $error',
    );

    if (message.contains('connection refused') ||
        message.contains('connection refused by host')) {
      return l10n.router_connection_refused;
    }

    if (message.contains('timed out') ||
        message.contains('timeout') ||
        message.contains('connection timed out')) {
      return l10n.router_connection_timeout;
    }

    if (message.contains('network is unreachable') ||
        message.contains('network unreachable')) {
      return l10n.router_network_unreachable;
    }

    if (message.contains('host is unreachable') ||
        message.contains('no route to host')) {
      return l10n.router_host_unreachable;
    }

    if (message.contains('socketexception')) {
      return l10n.router_connection_error;
    }

    return l10n.router_connection_error;
  }

  Future<bool> login({
    required String gateway,
    required int port,
    required BuildContext context,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    if (usernameController.text.trim().isEmpty) {
      _setError(
        l10n.router_enter_username,
      );

      return false;
    }

    if (passwordController.text.isEmpty) {
      _setError(
        l10n.router_enter_password,
      );

      return false;
    }

    if (gateway.trim().isEmpty || gateway.trim() == '0.0.0.0') {
      _setError(
        l10n.router_invalid_gateway,
      );

      return false;
    }

    _clearError();

    isLoading = true;

    status = l10n.router_connecting;

    notifyListeners();

    try {
      final tokenLoaded = await _loadToken(
        l10n: l10n,
      );

      if (!tokenLoaded) {
        return false;
      }

      status = l10n.router_loading_commands;

      notifyListeners();

      final commandsLoaded = await _loadRouterCommands(
        context: context,
        l10n: l10n,
      );

      if (!commandsLoaded) {
        return false;
      }

      debugPrint(
        '[RouterLoginPageController] '
        'LOGIN START',
      );

      debugPrint(
        'Router ID : $routerId',
      );

      debugPrint(
        'Gateway   : $gateway',
      );

      debugPrint(
        'Port      : $port',
      );

      debugPrint(
        'Router Username: '
        '${usernameController.text.trim()}',
      );

      status = l10n.router_connecting;

      notifyListeners();

      try {
        await telnetService.connect(
          host: gateway.trim(),
          port: port,
        );

        debugPrint(
          '[RouterLoginPageController] '
          'Telnet connected successfully',
        );
      } catch (e, stackTrace) {
        debugPrint(
          '[RouterLoginPageController] '
          'TELNET CONNECTION FAILED',
        );

        debugPrint(
          'Error: $e',
        );

        debugPrint(
          'StackTrace: $stackTrace',
        );

        status = l10n.router_connection_failed;

        errorMessage = _getUserFriendlyConnectionError(
          e,
          l10n,
        );

        notifyListeners();

        await disconnect();

        return false;
      }
      status = l10n.router_logging_in;

      notifyListeners();

      try {
        await telnetService.login(
          username: usernameController.text.trim(),
          password: passwordController.text,
        );

        debugPrint(
          '[RouterLoginPageController] '
          'Router login successful',
        );
      } catch (e, stackTrace) {
        debugPrint(
          '[RouterLoginPageController] '
          'TELNET LOGIN FAILED',
        );

        debugPrint(
          'Error: $e',
        );

        debugPrint(
          'StackTrace: $stackTrace',
        );

        status = l10n.router_login_failed;

        errorMessage = l10n.router_invalid_credentials;

        notifyListeners();

        await disconnect();

        return false;
      }

      status = l10n.router_verifying_subscription;

      notifyListeners();

      String pppoeOutput;

      try {
        pppoeOutput = await executePppoeCommands(
          l10n: l10n,
        );
      } catch (e, stackTrace) {
        debugPrint(
          '[RouterLoginPageController] '
          'PPPOE COMMANDS FAILED',
        );

        debugPrint(
          'Error: $e',
        );

        debugPrint(
          'StackTrace: $stackTrace',
        );

        status = l10n.router_verification_failed;

        errorMessage = l10n.router_subscription_verification_error;

        notifyListeners();

        await disconnect();

        return false;
      }

      debugPrint(
        '[RouterLoginPageController] '
        'PPPoE information received',
      );
      debugPrint(pppoeOutput);

      final wanInfo = _parseWanInfo(pppoeOutput);

      subscriberUsername = wanInfo['username'];

      connectionStatus = wanInfo['connectionStatus'];

      debugPrint(
        'Router PPPoE Username: '
        '$subscriberUsername',
      );

      debugPrint(
        'Connection Status: '
        '$connectionStatus',
      );

      await _loadSavedUsername();

      debugPrint(
        'Server Username: $savedUsername',
      );

      debugPrint(
        'Router Username: '
        '$subscriberUsername',
      );

      if (savedUsername == null || savedUsername!.trim().isEmpty) {
        debugPrint(
          '[RouterLoginPageController] '
          'No saved server username found',
        );

        status = l10n.router_subscriber_data_not_found;

        errorMessage = l10n.router_subscriber_data_not_found;

        notifyListeners();

        await disconnect();

        return false;
      }

      if (subscriberUsername == null || subscriberUsername!.trim().isEmpty) {
        debugPrint(
          '[RouterLoginPageController] '
          'Router PPPoE username not found',
        );

        status = l10n.router_username_not_found;

        errorMessage = l10n.router_username_not_found;

        notifyListeners();

        await disconnect();

        return false;
      }

      final normalizedSavedUsername = _normalize(savedUsername);

      final normalizedRouterUsername = _normalize(subscriberUsername);

      debugPrint(
        'Saved Server Username:',
      );

      debugPrint(
        normalizedSavedUsername,
      );

      debugPrint(
        'Router PPPoE Username:',
      );

      debugPrint(
        normalizedRouterUsername,
      );

      final bool usernameMatches =
          normalizedSavedUsername == normalizedRouterUsername;

      debugPrint(
        'Username Match: '
        '$usernameMatches',
      );

      if (!usernameMatches) {
        debugPrint(
          '[RouterLoginPageController] '
          'SUBSCRIBER DATA NOT MATCHED',
        );

        status = l10n.router_data_mismatch;

        errorMessage = l10n.router_data_mismatch;

        notifyListeners();

        await disconnect();

        return false;
      }

      debugPrint(
        '[RouterLoginPageController] '
        'SUBSCRIBER DATA MATCHED',
      );

      status = l10n.router_verification_success;

      errorMessage = null;

      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterLoginPageController] '
        'LOGIN ERROR',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );
      status = l10n.router_connection_failed;

      errorMessage = _getUserFriendlyConnectionError(
        e,
        l10n,
      );

      notifyListeners();

      await disconnect();

      return false;
    } finally {
      isLoading = false;

      notifyListeners();

      debugPrint(
        '[RouterLoginPageController] '
        'LOGIN END',
      );
    }
  }

  Future<bool> _loadToken({
    required AppLocalizations l10n,
  }) async {
    try {
      debugPrint(
        '[RouterLoginPageController] '
        'Loading saved token...',
      );

      final savedToken = await storage.getToken();

      if (savedToken == null || savedToken.trim().isEmpty) {
        _token = null;

        errorMessage = l10n.router_token_not_found;

        debugPrint(
          '[RouterLoginPageController] '
          'Token not found',
        );

        notifyListeners();

        return false;
      }

      _token = savedToken.trim();

      debugPrint(
        '[RouterLoginPageController] '
        'Token loaded successfully',
      );

      return true;
    } catch (e, stackTrace) {
      _token = null;

      debugPrint(
        '[RouterLoginPageController] '
        'TOKEN LOAD ERROR',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      errorMessage = l10n.router_login_data_error;

      notifyListeners();

      return false;
    }
  }

  Map<String, String> get _headers {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_token ?? ''}',
    };
  }

  Future<bool> _loadRouterCommands({
    required BuildContext context,
    required AppLocalizations l10n,
  }) async {
    try {
      final String path = '${AppApi.routermodel}'
          '/$routerId/'
          '${AppApi.routercommands}';

      final Uri url = Uri.parse(
        '${AppApi.url}$path',
      );

      debugPrint(
        '[RouterLoginPageController] '
        'Loading router commands',
      );

      debugPrint(
        'Router ID : $routerId',
      );

      debugPrint(
        'URL       : $url',
      );

      final response = await http.get(
        url,
        headers: _headers,
      );

      debugPrint(
        '[RouterLoginPageController] '
        'Commands status: '
        '${response.statusCode}',
      );

      // Debug فقط
      debugPrint(
        '[RouterLoginPageController] '
        'Commands body: '
        '${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          errorMessage = ApiErrorHandler.getUnhandledErrorMessage(
            context: context,
          );

          notifyListeners();

          return false;
        }

        final result = RouterCommandsResponse.fromJson(
          decoded,
        );

        if (!result.success) {
          errorMessage = l10n.router_commands_load_failed;

          debugPrint(
            '[RouterLoginPageController] '
            'Router command API returned failure: '
            '${result.message}',
          );

          notifyListeners();

          return false;
        }

        _commandsResponse = result;

        debugPrint(
          '[RouterLoginPageController] '
          'Router commands loaded successfully',
        );

        return true;
      }

      if (response.statusCode == 401 ||
          response.statusCode == 406 ||
          response.statusCode == 403 ||
          response.statusCode == 429) {
        final serverMessage = _getServerMessage(
          response.body,
        );

        debugPrint(
          '[RouterLoginPageController] '
          'SERVER MESSAGE: '
          '$serverMessage',
        );

        errorMessage = ApiErrorHandler.getUnhandledErrorMessage(
          context: context,
        );

        debugPrint(
          '[RouterLoginPageController] '
          'SERVER ERROR '
          '${response.statusCode}',
        );

        notifyListeners();

        return false;
      }

      errorMessage = ApiErrorHandler.getUnhandledErrorMessage(
        context: context,
      );

      debugPrint(
        '[RouterLoginPageController] '
        'HTTP ERROR: '
        '${response.statusCode}',
      );

      notifyListeners();

      return false;
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterLoginPageController] '
        'LOAD COMMANDS ERROR',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      errorMessage = l10n.router_commands_load_error;

      notifyListeners();

      return false;
    }
  }

  List<RouterCommand> get _pppoeCommands {
    return _commandsResponse?.data?.commands['PPPoE Settings']?.commands ?? [];
  }

  Future<String> executePppoeCommands({
    required AppLocalizations l10n,
  }) async {
    final commands = _pppoeCommands;

    if (commands.isEmpty) {
      debugPrint(
        '[RouterLoginPageController] '
        'No PPPoE commands found',
      );

      throw Exception(
        'PPPoE commands not found',
      );
    }

    final StringBuffer allOutput = StringBuffer();

    debugPrint(
      '[RouterLoginPageController] '
      'Found ${commands.length} PPPoE commands',
    );

    for (int i = 0; i < commands.length; i++) {
      final command = commands[i];

      // --------------------------------------------------------
      // RAW COMMAND
      // --------------------------------------------------------

      final rawCommand = command.command;

      // --------------------------------------------------------
      // CLEAN COMMAND
      // --------------------------------------------------------

      final cleanCommand = rawCommand
          .replaceAll(
            RegExp(r'^\d+-'),
            '',
          )
          .trim();

      if (cleanCommand.isEmpty) {
        debugPrint(
          '[RouterLoginPageController] '
          'Skipping empty command',
        );

        continue;
      }

      debugPrint(
        '[RouterLoginPageController] '
        'Executing server command '
        '${i + 1}/${commands.length}',
      );

      debugPrint(
        'Command ID    : '
        '${command.id}',
      );

      debugPrint(
        'Raw Command   : '
        '$rawCommand',
      );

      debugPrint(
        'Clean Command : '
        '$cleanCommand',
      );

      final output = await telnetService.execute(
        cleanCommand,
        timeout: const Duration(
          seconds: 10,
        ),
        waitForPrompt: true,
      );

      debugPrint(
        '[RouterLoginPageController] '
        'Command output:',
      );

      debugPrint(output);

      allOutput.writeln(output);

      if (command.expectedOutput.trim().isNotEmpty) {
        debugPrint(
          '[RouterLoginPageController] '
          'Expected:',
        );

        debugPrint(
          command.expectedOutput,
        );
      }
    }

    debugPrint(
      '[RouterLoginPageController] '
      'ALL PPPoE COMMANDS COMPLETED',
    );

    return allOutput.toString();
  }

  Future<void> _loadSavedUsername() async {
    try {
      savedUsername = await storage.getUsername();

      debugPrint(
        '[RouterLoginPageController] '
        'Loaded Server Username: '
        '$savedUsername',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterLoginPageController] '
        'Failed loading saved username',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      savedUsername = null;
    }
  }

  String _normalize(String? value) {
    if (value == null) {
      return '';
    }

    final normalized = value.trim().toLowerCase();

    return normalized.split('@').first.trim();
  }

  Map<String, String> _parseWanInfo(
    String output,
  ) {
    String? username;

    String? connectionStatus;

    debugPrint(
      '[RouterLoginPageController] '
      'Parsing PPPoE output...',
    );

    for (final rawLine in output.split(
      RegExp(r'\r?\n'),
    )) {
      var line = rawLine.trim();

      if (line.isEmpty) {
        continue;
      }

      debugPrint(
        '[RouterLoginPageController] '
        'Parsing line: "$line"',
      );

      line = line.replaceAll('\r', '').trim();

      final usernameMatch = RegExp(
        r'^username\s*(?:=|:|\s)\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);

      if (usernameMatch != null) {
        var value = usernameMatch.group(1)?.trim() ?? '';

        value = value.replaceAll('"', '').replaceAll("'", '').trim();

        value = value
            .replaceAll(
              RegExp(r'[}\s]+$'),
              '',
            )
            .trim();

        if (value.isNotEmpty) {
          username = value;

          debugPrint(
            '[RouterLoginPageController] '
            'PPPoE Username found: '
            '$username',
          );
        }

        continue;
      }

      final connectionMatch = RegExp(
        r'^connectionStatus\s*(?:=|:|\s)\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);

      if (connectionMatch != null) {
        var value = connectionMatch.group(1)?.trim() ?? '';

        value = value.replaceAll('"', '').replaceAll("'", '').trim();

        value = value
            .replaceAll(
              RegExp(r'[}\s]+$'),
              '',
            )
            .trim();

        if (value.isNotEmpty) {
          connectionStatus = value;

          debugPrint(
            '[RouterLoginPageController] '
            'Connection Status found: '
            '$connectionStatus',
          );
        }

        continue;
      }

      final stateMatch = RegExp(
        r'^state\s*(?:=|:|\s)\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);

      if (stateMatch != null) {
        var value = stateMatch.group(1)?.trim() ?? '';

        value = value.replaceAll('"', '').replaceAll("'", '').trim();

        value = value
            .replaceFirst(
              RegExp(
                r'\s+Disable\s+\d+.*$',
                caseSensitive: false,
              ),
              '',
            )
            .trim();

        value = value
            .replaceAll(
              RegExp(r'[}\s]+$'),
              '',
            )
            .trim();

        if (value.isNotEmpty) {
          connectionStatus = value;

          debugPrint(
            '[RouterLoginPageController] '
            'Connection Status found: '
            '$connectionStatus',
          );
        }

        continue;
      }
    }

    debugPrint(
      '[RouterLoginPageController] '
      'Parsed PPPoE username: '
      '${username ?? ''}',
    );

    debugPrint(
      '[RouterLoginPageController] '
      'Parsed connection status: '
      '${connectionStatus ?? ''}',
    );

    return {
      'username': username ?? '',
      'connectionStatus': connectionStatus ?? '',
    };
  }

  Future<void> disconnect() async {
    try {
      await telnetService.disconnect();
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterLoginPageController] '
        'Disconnect error',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );
    }
  }

  void _setError(
    String message,
  ) {
    errorMessage = message;

    status = '';

    notifyListeners();
  }

  void _clearError() {
    errorMessage = null;
  }

  void clearError() {
    errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();

    passwordController.dispose();

    if (!_serviceTransferred) {
      telnetService.disconnect();
    }

    super.dispose();
  }
}
