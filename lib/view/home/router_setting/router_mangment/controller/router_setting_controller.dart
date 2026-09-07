import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:omniya/core/const/url.dart';
import 'package:omniya/core/services/auth_storage.dart';
import 'package:omniya/model/setting/router_commands_response.dart';

class RouterSettingController extends ChangeNotifier {
  bool _isLoading = false;

  String? _errorMessage;

  RouterCommandsResponse? _response;

  final AuthStorage _authStorage = AuthStorage();

  String? _token;

  String? get token => _token;

  bool get isLoading => _isLoading;

  bool get hasError => _errorMessage != null;

  String? get errorMessage => _errorMessage;

  RouterCommandsResponse? get response => _response;

  RouterCommandsData? get data => _response?.data;

  Map<String, RouterCommandCategory> get commands =>
      _response?.data?.commands ?? {};

  Map<String, String> get _headers {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${(_token ?? '').trim()}',
    };
  }

  // ============================================================
  // LOAD TOKEN
  // ============================================================

  Future<bool> _loadToken() async {
    try {
      debugPrint(
        '[RouterSettingController] Loading saved token...',
      );

      final String? savedToken = await _authStorage.getToken();

      if (savedToken == null || savedToken.trim().isEmpty) {
        _token = null;

        debugPrint(
          '[RouterSettingController] ERROR: Token not found',
        );

        _errorMessage =
            'لم يتم العثور على رمز الدخول. يرجى تسجيل الدخول مرة أخرى.';

        return false;
      }

      _token = savedToken.trim();

      debugPrint(
        '[RouterSettingController] Token loaded successfully',
      );

      debugPrint(
        '[RouterSettingController] Token exists: ${_token!.isNotEmpty}',
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterSettingController] TOKEN LOAD ERROR',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      _token = null;

      _errorMessage = 'تعذر قراءة بيانات تسجيل الدخول.';

      return false;
    }
  }

  // ============================================================
  // GET ROUTER COMMANDS
  // ============================================================

  Future<bool> getCommandDetails(
    int routerId,
  ) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      final bool tokenLoaded = await _loadToken();

      if (!tokenLoaded) {
        return false;
      }
      final String path =
          '${AppApi.routermodel}/$routerId/${AppApi.routercommands}';

      final Uri url = Uri.parse(
        '${AppApi.url}$path',
      );

      debugPrint(
        '[RouterSettingController] GET ROUTER COMMANDS',
      );

      debugPrint(
        'Router ID : $routerId',
      );

      debugPrint(
        'URL       : $url',
      );

      debugPrint(
        'AUTH TOKEN EXISTS: '
        '${_token != null && _token!.isNotEmpty}',
      );

      final http.Response response = await http.get(
        url,
        headers: _headers,
      );

      debugPrint(
        '[RouterSettingController] Status: '
        '${response.statusCode}',
      );

      debugPrint(
        '[RouterSettingController] Body: '
        '${response.body}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        dynamic decoded;

        try {
          decoded = jsonDecode(response.body);
        } catch (e) {
          _errorMessage = 'استجابة غير صحيحة من الخادم.';

          debugPrint(
            '[RouterSettingController] JSON DECODE ERROR',
          );

          debugPrint(
            'Error: $e',
          );

          return false;
        }

        if (decoded is! Map<String, dynamic>) {
          _errorMessage = 'استجابة غير صحيحة من الخادم.';

          debugPrint(
            '[RouterSettingController] '
            'INVALID JSON RESPONSE TYPE',
          );

          return false;
        }

        final RouterCommandsResponse result = RouterCommandsResponse.fromJson(
          decoded,
        );

        _response = result;

        if (result.success) {
          _errorMessage = null;

          debugPrint(
            '[RouterSettingController] '
            'Commands loaded successfully',
          );

          debugPrint(
            '[RouterSettingController] '
            'Categories: ${commands.length}',
          );

          debugPrint(
            '[RouterSettingController] '
            'Total commands: $totalCommands',
          );

          return true;
        }

        _errorMessage = result.message ?? 'فشل في جلب أوامر الراوتر.';

        debugPrint(
          '[RouterSettingController] '
          'API returned success=false',
        );

        debugPrint(
          '[RouterSettingController] '
          'Message: $_errorMessage',
        );

        return false;
      }

      if (response.statusCode == 401) {
        _errorMessage = 'انتهت جلسة تسجيل الدخول. يرجى تسجيل الدخول مرة أخرى.';

        debugPrint(
          '[RouterSettingController] 401 Unauthorized',
        );

        return false;
      }

      if (response.statusCode == 403) {
        _errorMessage = 'ليس لديك صلاحية للوصول إلى أوامر الراوتر.';

        debugPrint(
          '[RouterSettingController] 403 Forbidden',
        );

        return false;
      }

      try {
        final dynamic errorJson = jsonDecode(response.body);

        if (errorJson is Map<String, dynamic>) {
          _errorMessage = errorJson['message']?.toString() ??
              'حدث خطأ في الاتصال بالخادم '
                  '(${response.statusCode})';
        } else {
          _errorMessage = 'حدث خطأ في الاتصال بالخادم '
              '(${response.statusCode})';
        }
      } catch (_) {
        _errorMessage = 'حدث خطأ في الاتصال بالخادم '
            '(${response.statusCode})';
      }

      debugPrint(
        '[RouterSettingController] HTTP ERROR',
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );

      debugPrint(
        'Message: $_errorMessage',
      );

      return false;
    } catch (e, stackTrace) {
      debugPrint('');

      debugPrint(
        '[RouterSettingController] GET COMMANDS ERROR',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      _errorMessage = 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(
    bool value,
  ) {
    _isLoading = value;

    notifyListeners();
  }

  void clear() {
    _response = null;

    _errorMessage = null;

    _isLoading = false;

    _token = null;

    notifyListeners();
  }

  int get totalCommands {
    int total = 0;

    for (final RouterCommandCategory category in commands.values) {
      total += category.commands.length;
    }

    return total;
  }

  RouterCommandCategory? getCategory(
    String categoryName,
  ) {
    return commands[categoryName];
  }

  List<RouterCommand> getCommandsByCategory(
    String categoryName,
  ) {
    return commands[categoryName]?.commands ?? [];
  }

  RouterCommand? getCommandById(
    int commandId,
  ) {
    for (final RouterCommandCategory category in commands.values) {
      for (final RouterCommand command in category.commands) {
        if (command.id == commandId) {
          return command;
        }
      }
    }

    return null;
  }

  RouterCommand? findCommand(
    String commandText,
  ) {
    final String target = commandText.trim();

    for (final RouterCommandCategory category in commands.values) {
      for (final RouterCommand command in category.commands) {
        if (command.command.trim() == target) {
          return command;
        }
      }
    }

    return null;
  }

  List<RouterCommand> get wifiCommands {
    return getCommandsByCategory(
      'Wi-Fi Configuration',
    );
  }

  List<RouterCommand> get connectionCommands {
    return getCommandsByCategory(
      'Connection Management',
    );
  }

  List<RouterCommand> get pppoeCommands {
    return getCommandsByCategory(
      'PPPoE Settings',
    );
  }

  List<RouterCommand> get lineStatisticsCommands {
    return getCommandsByCategory(
      'Line Statistics',
    );
  }

  String buildCommand(
    String command,
    Map<String, String> parameters,
  ) {
    String result = command;

    parameters.forEach(
      (String key, String value) {
        result = result.replaceAll(
          '{$key}',
          value,
        );
      },
    );

    return result;
  }

  String buildRouterCommand(
    RouterCommand command,
    Map<String, String> parameters,
  ) {
    return buildCommand(
      command.command,
      parameters,
    );
  }

  String? buildWifiPasswordCommand(
    String password, {
    int commandIndex = 0,
  }) {
    if (wifiCommands.isEmpty) {
      return null;
    }

    if (commandIndex < 0 || commandIndex >= wifiCommands.length) {
      return null;
    }

    final RouterCommand command = wifiCommands[commandIndex];

    return buildRouterCommand(
      command,
      {
        'password': password,
      },
    );
  }

  RouterCommand? findWifiPasswordCommand() {
    for (final RouterCommandCategory category in commands.values) {
      for (final RouterCommand command in category.commands) {
        final String value = command.command.toLowerCase();

        if (value.contains('{password}') ||
            value.contains('passphrase') ||
            value.contains('password') ||
            value.contains('psk')) {
          return command;
        }
      }
    }

    return null;
  }

  @override
  void dispose() {
    debugPrint(
      '[RouterSettingController] DISPOSE',
    );

    super.dispose();
  }
}
