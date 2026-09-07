import 'package:flutter/foundation.dart';

import 'package:omniya/model/setting/router_commands_response.dart';
import 'package:omniya/view/home/router_setting/router_mangment/controller/router_setting_controller.dart';
import 'package:omniya/view/home/router_setting/router_mangment/service/router_report_service.dart';
import 'package:omniya/view/home/router_setting/router_telnet_split/router_telnet_service.dart';

class RouterManagementController extends ChangeNotifier {
  final RouterSettingController settingController;
  final RouterTelnetService telnetService;
  final int routerId;
  final bool _ownsSettingController;
  late final RouterReportService reportService;
  bool _isDisposed = false;
  bool _commandsLoaded = false;
  bool _isLoadingCommands = false;
  bool _isChangingPassword = false;

  String? _passwordError;
  String? _passwordSuccess;

  bool _showLineStatistics = false;
  bool _isLoadingLineStatistics = false;

  String? _lineStatisticsOutput;
  String? _lineStatisticsError;

  Map<String, String> _lineStatisticsValues = {};

  RouterManagementController({
    required this.routerId,
    required this.telnetService,
    RouterSettingController? settingController,
  })  : settingController = settingController ?? RouterSettingController(),
        _ownsSettingController = settingController == null;

  void _safeNotify() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }

  bool get commandsLoaded => _commandsLoaded;

  bool get isLoadingCommands => _isLoadingCommands;

  bool get isChangingPassword => _isChangingPassword;

  String? get passwordError => _passwordError;

  String? get passwordSuccess => _passwordSuccess;

  bool get showLineStatistics => _showLineStatistics;

  bool get isLoadingLineStatistics => _isLoadingLineStatistics;

  String? get lineStatisticsOutput => _lineStatisticsOutput;

  String? get lineStatisticsError => _lineStatisticsError;

  Map<String, String> get lineStatisticsValues =>
      Map.unmodifiable(_lineStatisticsValues);

  bool get isLoading => settingController.isLoading;

  bool get hasError => settingController.hasError;

  String? get errorMessage => settingController.errorMessage;

  RouterCommandsResponse? get response => settingController.response;

  Map<String, RouterCommandCategory> get commands => settingController.commands;

  List<RouterCommand> get lineStatisticsCommands =>
      settingController.lineStatisticsCommands;

  bool get supports2G => wifi2gCommand != null;

  bool get supports5G => wifi5gCommand != null;

  bool get supportsDualBand => supports2G && supports5G;

  bool get supportsSingleBand =>
      (supports2G && !supports5G) || (!supports2G && supports5G);

  String? get downstreamRate => _lineStatisticsValues['downstreamRate'];

  String? get upstreamRate => _lineStatisticsValues['upstreamRate'];

  String? get downstreamSpeed => _lineStatisticsValues['downstreamRate'];

  String? get upstreamSpeed => _lineStatisticsValues['upstreamRate'];

  String? get downstreamSnr => _lineStatisticsValues['downstreamSnr'];

  String? get upstreamSnr => _lineStatisticsValues['upstreamSnr'];

  String? get downstreamAttenuation =>
      _lineStatisticsValues['downstreamAttenuation'];

  String? get upstreamAttenuation =>
      _lineStatisticsValues['upstreamAttenuation'];

  String? get downstreamCrc => _lineStatisticsValues['downstreamCrc'];

  String? get upstreamCrc => _lineStatisticsValues['upstreamCrc'];

  String? get downstreamEs => _lineStatisticsValues['downstreamEs'];

  String? get upstreamEs => _lineStatisticsValues['upstreamEs'];

  String? get es => _lineStatisticsValues['es'];

  String? get downstreamSes => _lineStatisticsValues['downstreamSes'];

  String? get upstreamSes => _lineStatisticsValues['upstreamSes'];

  String? get ses => _lineStatisticsValues['ses'];

  String? get lineStatus => _lineStatisticsValues['lineStatus'];

  Future<bool> loadRouterCommands({
    bool force = false,
  }) async {
    if (_isDisposed) {
      return false;
    }

    if (_commandsLoaded && !force) {
      return true;
    }

    if (_isLoadingCommands) {
      return false;
    }

    _isLoadingCommands = true;

    _safeNotify();

    try {
      final bool success = await settingController.getCommandDetails(routerId);

      if (_isDisposed) {
        return false;
      }

      if (!success) {
        _commandsLoaded = true;

        debugPrint(
          '[RouterManagementController] COMMANDS LOADED',
        );

        _printCommands();

        if (lineStatisticsCommands.isNotEmpty) {
          debugPrint(
            '[RouterManagementController] '
            'LINE STATISTICS COMMAND FOUND',
          );

          await loadLineStatistics();
        } else {
          debugPrint(
            '[RouterManagementController] '
            'NO LINE STATISTICS COMMAND',
          );

          clearLineStatistics(
            notify: false,
          );
        }

        return true;
      }

      _commandsLoaded = true;

      debugPrint(
        '[RouterManagementController] COMMANDS LOADED',
      );

      _printCommands();

      return true;
    } catch (e, stackTrace) {
      if (_isDisposed) {
        return false;
      }

      _commandsLoaded = false;

      debugPrint(
        '[RouterManagementController] COMMANDS EXCEPTION',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      return false;
    } finally {
      _isLoadingCommands = false;

      _safeNotify();
    }
  }

  Future<bool> refreshCommands() async {
    if (_isDisposed) {
      return false;
    }

    _commandsLoaded = false;

    clearLineStatistics(
      notify: false,
    );

    return loadRouterCommands(
      force: true,
    );
  }

  Future<bool> retry() async {
    if (_isDisposed) {
      return false;
    }

    _commandsLoaded = false;

    clearLineStatistics(
      notify: false,
    );

    return loadRouterCommands(
      force: true,
    );
  }

  int get totalCommands {
    int total = 0;

    for (final RouterCommandCategory category in commands.values) {
      total += category.commands.length;
    }

    return total;
  }

  String? _findGenericWifiPasswordCommand() {
    for (final RouterCommandCategory category in commands.values) {
      for (final RouterCommand command in category.commands) {
        final String value = command.command.trim().toLowerCase();

        if (value.contains('wlctl') &&
            value.contains('set') &&
            value.contains('psk')) {
          return command.command;
        }

        if (value.contains('password') ||
            value.contains('passphrase') ||
            value.contains('wpa') ||
            value.contains('psk')) {
          return command.command;
        }
      }
    }

    return null;
  }

  String? get wifi2gCommand {
    return _findWifiPasswordCommand(
      band: '2g',
    );
  }

  String? get wifi5gCommand {
    return _findWifiPasswordCommand(
      band: '5g',
    );
  }

  String? _findWifiPasswordCommand({
    required String band,
  }) {
    for (final RouterCommandCategory category in commands.values) {
      for (final RouterCommand command in category.commands) {
        final String value = command.command.trim().toLowerCase();

        if (value.contains('wlctl') &&
            value.contains('set') &&
            value.contains(band) &&
            value.contains('psk')) {
          return command.command;
        }
      }
    }

    for (final RouterCommandCategory category in commands.values) {
      for (final RouterCommand command in category.commands) {
        final String value = command.command.trim().toLowerCase();

        if (value.contains('wlctl set $band')) {
          return command.command;
        }
      }
    }

    return null;
  }

  Future<bool> changeWifiPassword({
    required String password,
    required bool is5G,
  }) async {
    if (_isDisposed) {
      return false;
    }

    _passwordError = null;
    _passwordSuccess = null;

    final String cleanPassword = password.trim();

    if (cleanPassword.isEmpty) {
      _passwordError = 'يرجى إدخال كلمة المرور';
      _safeNotify();
      return false;
    }

    if (cleanPassword.length < 8) {
      _passwordError = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
      _safeNotify();
      return false;
    }

    if (cleanPassword.contains(' ')) {
      _passwordError = 'كلمة المرور يجب ألا تحتوي على مسافات';
      _safeNotify();
      return false;
    }

    if (!telnetService.isConnected) {
      _passwordError = 'الاتصال بالراوتر غير موجود';
      _safeNotify();
      return false;
    }

    if (_isChangingPassword) {
      _passwordError = 'يوجد طلب آخر جارٍ لتغيير كلمة المرور';
      _safeNotify();
      return false;
    }

    if (!_commandsLoaded) {
      final bool loaded = await loadRouterCommands();

      if (_isDisposed) {
        return false;
      }

      if (!loaded) {
        _passwordError = 'تعذر تحميل أوامر الراوتر';
        _safeNotify();
        return false;
      }
    }

    String? template = is5G ? wifi5gCommand : wifi2gCommand;

    template ??= _findGenericWifiPasswordCommand();

    if (template == null || template.trim().isEmpty) {
      _passwordError = 'لم يتم العثور على أمر تغيير كلمة مرور Wi-Fi';

      _safeNotify();
      return false;
    }

    final bool hasPasswordPlaceholder = RegExp(
      r'\{password\}',
      caseSensitive: false,
    ).hasMatch(template);

    if (!hasPasswordPlaceholder) {
      _passwordError = 'أمر تغيير كلمة المرور غير صالح: '
          'لم يتم العثور على {password}';

      debugPrint(
        '[RouterManagementController] '
        'PASSWORD PLACEHOLDER NOT FOUND',
      );

      debugPrint(
        'Template: ${_hidePassword(template)}',
      );

      _safeNotify();
      return false;
    }

    final String command = template.replaceFirst(
      RegExp(
        r'\{password\}',
        caseSensitive: false,
      ),
      cleanPassword,
    );

    _isChangingPassword = true;
    _safeNotify();

    debugPrint(
      '[RouterManagementController] CHANGE WIFI PASSWORD',
    );

    debugPrint(
      'Band: ${is5G ? '5GHz' : '2.4GHz'}',
    );

    debugPrint(
      'Password Command: ${_hidePassword(command)}',
    );

    try {
      // ============================================================
      // STEP 1
      // هل الراوتر يحتاج الدخول إلى shell؟
      // ============================================================

      final String? shellCommand = _findShellCommand();

      if (shellCommand != null && shellCommand.trim().isNotEmpty) {
        debugPrint(
          '[RouterManagementController] '
          'SHELL COMMAND FOUND',
        );

        debugPrint(
          'Shell Command: $shellCommand',
        );

        final String shellOutput = await telnetService.changeWifiPassword(
          shellCommand.trim(),
          timeout: const Duration(
            seconds: 10,
          ),
        );

        debugPrint(
          '[RouterManagementController] '
          'SHELL RESPONSE',
        );

        debugPrint(shellOutput);

        if (!_isSuccessfulPasswordResponse(shellOutput)) {
          _passwordError = _extractCommandError(
            shellOutput,
          );

          return false;
        }

        debugPrint(
          '[RouterManagementController] '
          'SHELL STEP SUCCESS',
        );
      } else {
        debugPrint(
          '[RouterManagementController] '
          'NO SHELL COMMAND - SKIPPING',
        );
      }

      // ============================================================
      // STEP 2
      // تغيير كلمة المرور
      // ============================================================

      debugPrint(
        '[RouterManagementController] '
        'EXECUTING PASSWORD COMMAND',
      );

      final String output = await telnetService.changeWifiPassword(
        command,
        timeout: const Duration(
          seconds: 10,
        ),
      );

      if (_isDisposed) {
        return false;
      }

      debugPrint(
        '[RouterManagementController] '
        'PASSWORD RESPONSE',
      );

      debugPrint(
        _sanitizeOutput(output),
      );

      final bool success = _isSuccessfulPasswordResponse(output);

      if (!success) {
        _passwordError = _extractCommandError(output);

        return false;
      }

      debugPrint(
        '[RouterManagementController] '
        'PASSWORD COMMAND SUCCESS',
      );

      // ============================================================
      // STEP 3
      // هل يحتاج الراوتر إلى restart للـ WLAN؟
      // ============================================================

      final String? restartCommand = _findWifiRestartCommand();

      if (restartCommand != null && restartCommand.trim().isNotEmpty) {
        debugPrint(
          '[RouterManagementController] '
          'WIFI RESTART COMMAND FOUND',
        );

        debugPrint(
          'Restart Command: $restartCommand',
        );

        final String restartOutput = await telnetService.changeWifiPassword(
          restartCommand.trim(),
          timeout: const Duration(
            seconds: 10,
          ),
        );

        debugPrint(
          '[RouterManagementController] '
          'WIFI RESTART RESPONSE',
        );

        debugPrint(restartOutput);

        if (!_isSuccessfulPasswordResponse(
          restartOutput,
        )) {
          _passwordError = _extractCommandError(
            restartOutput,
          );

          return false;
        }

        debugPrint(
          '[RouterManagementController] '
          'WIFI RESTART SUCCESS',
        );
      } else {
        debugPrint(
          '[RouterManagementController] '
          'NO WIFI RESTART COMMAND - SKIPPING',
        );
      }

      // ============================================================
      // SUCCESS
      // ============================================================

      _passwordSuccess = is5G
          ? 'تم تغيير كلمة مرور شبكة 5GHz بنجاح'
          : 'تم تغيير كلمة مرور شبكة 2.4GHz بنجاح';

      return true;
    } catch (e, stackTrace) {
      if (_isDisposed) {
        return false;
      }

      debugPrint(
        '[RouterManagementController] '
        'CHANGE PASSWORD ERROR',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      _passwordError = _getFriendlyTelnetError(
        e,
        defaultMessage: 'تعذر تغيير كلمة مرور شبكة Wi-Fi',
      );

      return false;
    } finally {
      if (!_isDisposed) {
        _isChangingPassword = false;
        _safeNotify();
      }
    }
  }

  String? _findShellCommand() {
    for (final RouterCommandCategory category in commands.values) {
      for (final RouterCommand command in category.commands) {
        final String value = command.command.trim().toLowerCase();

        if (value == 'sh') {
          return command.command.trim();
        }

        if (value == 'shell') {
          return command.command.trim();
        }
      }
    }

    return null;
  }

  String? _findWifiRestartCommand() {
    for (final RouterCommandCategory category in commands.values) {
      for (final RouterCommand command in category.commands) {
        final String value = command.command.trim().toLowerCase();

        if (value == 'config wlan restart') {
          return command.command.trim();
        }
      }
    }

    return null;
  }

  Future<bool> loadLineStatistics() async {
    if (_isDisposed) {
      return false;
    }

    if (_isLoadingLineStatistics) {
      return false;
    }

    if (_isChangingPassword) {
      _lineStatisticsError = 'يرجى الانتظار حتى انتهاء تغيير كلمة مرور Wi-Fi';

      _safeNotify();

      return false;
    }

    _lineStatisticsError = null;
    _lineStatisticsOutput = null;
    _lineStatisticsValues = {};

    if (!telnetService.isConnected) {
      _lineStatisticsError = 'الاتصال بالراوتر غير موجود. '
          'يجب إبقاء اتصال Telnet مفتوحاً.';

      _safeNotify();

      return false;
    }

    if (!_commandsLoaded) {
      final bool loaded = await loadRouterCommands();

      if (_isDisposed) {
        return false;
      }

      if (!loaded) {
        _lineStatisticsError = 'تعذر تحميل أوامر الراوتر';

        _safeNotify();

        return false;
      }
    }

    final List<RouterCommand> statisticsCommands =
        settingController.lineStatisticsCommands;

    if (statisticsCommands.isEmpty) {
      _lineStatisticsError = 'لم يتم العثور على أمر إحصائيات الخط';

      _safeNotify();

      return false;
    }

    final RouterCommand command = statisticsCommands.first;

    final String rawCommand = command.command.trim();

    if (rawCommand.isEmpty) {
      _lineStatisticsError = 'أمر إحصائيات الخط فارغ';

      _safeNotify();

      return false;
    }

    _isLoadingLineStatistics = true;
    _showLineStatistics = false;

    _safeNotify();

    try {
      final String output = await telnetService.getLineStatistics(
        rawCommand,
        timeout: const Duration(
          seconds: 15,
        ),
      );

      if (_isDisposed) {
        return false;
      }
      debugPrint(
        '[LINE STATISTICS RAW OUTPUT]',
      );

      debugPrint(output);

      if (output.trim().isEmpty) {
        _lineStatisticsError = 'الراوتر لم يعطِ أي بيانات لإحصائيات الخط';

        _lineStatisticsOutput = '';

        _lineStatisticsValues = {};

        return false;
      }

      _lineStatisticsOutput = output;

      final Map<String, String> parsed = parseLineStatistics(output);

      _lineStatisticsValues = parsed;

      debugPrint(
        '[PARSED LINE STATISTICS]',
      );

      parsed.forEach(
        (key, value) {
          debugPrint(
            '$key = $value',
          );
        },
      );

      if (parsed.isEmpty) {
        _lineStatisticsError = 'تعذر تحليل بيانات إحصائيات الخط';

        return false;
      }

      _lineStatisticsError = null;
      _showLineStatistics = true;

      return true;
    } catch (e) {
      if (_isDisposed) {
        return false;
      }

      _lineStatisticsError = _getFriendlyTelnetError(
        e,
        defaultMessage: 'تعذر الحصول على إحصائيات الخط',
      );

      return false;
    } finally {
      if (!_isDisposed) {
        _isLoadingLineStatistics = false;

        _safeNotify();
      }
    }
  }

  Map<String, String> parseLineStatistics(
    String output,
  ) {
    final Map<String, String> result = {};

    if (output.trim().isEmpty) {
      return result;
    }

    final String normalizedOutput =
        output.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final List<String> lines = normalizedOutput.split('\n');

    for (final String originalLine in lines) {
      final String line = originalLine.trim();

      if (line.isEmpty) {
        continue;
      }

      if (_isCommandOrPrompt(line)) {
        continue;
      }

      debugPrint(
        '[STATISTICS LINE] $line',
      );

      final RegExpMatch? equalsMatch = RegExp(
        r'^(.+?)\s*=\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);

      if (equalsMatch != null) {
        final String key = equalsMatch.group(1)!.trim();

        final String value = equalsMatch.group(2)!.trim();

        _parseGenericKeyValue(
          key: key,
          value: value,
          result: result,
        );

        continue;
      }

      final RegExpMatch? colonMatch = RegExp(
        r'^(.+?)\s*:\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);

      if (colonMatch != null) {
        final String key = colonMatch.group(1)!.trim();

        final String value = colonMatch.group(2)!.trim();

        _parseGenericKeyValue(
          key: key,
          value: value,
          result: result,
        );

        continue;
      }

      _parseFlexibleLine(
        line,
        result,
      );
    }

    return result;
  }

  void _parseGenericKeyValue({
    required String key,
    required String value,
    required Map<String, String> result,
  }) {
    final String normalizedKey = _normalize(key);

    if (normalizedKey == 'downstreamcurrrate') {
      final String? parsedValue = _extractFirstNumber(value);

      if (parsedValue != null && parsedValue.trim().isNotEmpty) {
        result['downstreamRate'] = parsedValue.trim();

        debugPrint(
          '[STATISTICS] CURRENT DOWNSTREAM RATE SELECTED: '
          '${parsedValue.trim()}',
        );
      }

      return;
    }

    if (normalizedKey == 'upstreamcurrrate') {
      final String? parsedValue = _extractFirstNumber(value);

      if (parsedValue != null && parsedValue.trim().isNotEmpty) {
        result['upstreamRate'] = parsedValue.trim();

        debugPrint(
          '[STATISTICS] CURRENT UPSTREAM RATE SELECTED: '
          '${parsedValue.trim()}',
        );
      }

      return;
    }

    if (normalizedKey == 'downstreammaxrate') {
      final String? parsedValue = _extractFirstNumber(value);

      if (parsedValue != null && parsedValue.trim().isNotEmpty) {
        result['downstreamMaxRate'] = parsedValue.trim();

        debugPrint(
          '[STATISTICS] DOWNSTREAM MAX RATE: '
          '${parsedValue.trim()}',
        );
      }

      return;
    }

    if (normalizedKey == 'upstreammaxrate') {
      final String? parsedValue = _extractFirstNumber(value);

      if (parsedValue != null && parsedValue.trim().isNotEmpty) {
        result['upstreamMaxRate'] = parsedValue.trim();

        debugPrint(
          '[STATISTICS] UPSTREAM MAX RATE: '
          '${parsedValue.trim()}',
        );
      }

      return;
    }

    if (normalizedKey == 'upstreamnoisemargin') {
      final String? parsedValue = _extractFirstNumber(value);

      if (parsedValue != null) {
        result['upstreamSnr'] = _formatDecimalMetric(
          parsedValue,
        );

        debugPrint(
          '[STATISTICS] UPSTREAM SNR: '
          '${result['upstreamSnr']}',
        );
      }

      return;
    }

    if (normalizedKey == 'downstreamnoisemargin') {
      final String? parsedValue = _extractFirstNumber(value);

      if (parsedValue != null) {
        result['downstreamSnr'] = _formatDecimalMetric(
          parsedValue,
        );

        debugPrint(
          '[STATISTICS] DOWNSTREAM SNR: '
          '${result['downstreamSnr']}',
        );
      }

      return;
    }

    if (normalizedKey == 'upstreamattenuation') {
      final String? parsedValue = _extractFirstNumber(value);

      if (parsedValue != null) {
        result['upstreamAttenuation'] = _formatDecimalMetric(
          parsedValue,
        );

        debugPrint(
          '[STATISTICS] UPSTREAM ATTENUATION: '
          '${result['upstreamAttenuation']}',
        );
      }

      return;
    }

    if (normalizedKey == 'downstreamattenuation') {
      final String? parsedValue = _extractFirstNumber(value);

      if (parsedValue != null) {
        result['downstreamAttenuation'] = _formatDecimalMetric(
          parsedValue,
        );

        debugPrint(
          '[STATISTICS] DOWNSTREAM ATTENUATION: '
          '${result['downstreamAttenuation']}',
        );
      }

      return;
    }

    if (_isStatusKey(normalizedKey)) {
      final String status = _cleanStatusValue(value);

      if (status.isNotEmpty) {
        result['lineStatus'] = status;
      }

      return;
    }

    final _LineMetric metric = _detectMetric(normalizedKey);

    if (metric == _LineMetric.unknown) {
      return;
    }

    final _LineDirection direction = _detectDirection(
      normalizedKey,
    );

    String? parsedValue = _extractBestValue(
      value,
      metric,
    );

    parsedValue ??= _extractFirstNumber(value);

    if (parsedValue == null || parsedValue.trim().isEmpty) {
      return;
    }

    _saveMetricValue(
      result: result,
      direction: direction,
      metric: metric,
      value: parsedValue.trim(),
    );
  }

  String _formatDecimalMetric(
    String value,
  ) {
    final String clean = value.trim();

    if (clean.isEmpty) {
      return clean;
    }

    final double? number = double.tryParse(clean);

    if (number == null) {
      return clean;
    }

    if (clean.contains('.')) {
      return _removeTrailingZeros(number);
    }

    final double converted = number / 10.0;

    return _removeTrailingZeros(converted);
  }

  String _removeTrailingZeros(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  void _parseFlexibleLine(
    String line,
    Map<String, String> result,
  ) {
    final String normalized = _normalize(line);

    if (normalized.isEmpty) {
      return;
    }

    if (_isStatusKey(normalized)) {
      final String? status = _extractStatusValue(line);

      if (status != null && status.trim().isNotEmpty) {
        result['lineStatus'] = status.trim();
      }

      return;
    }

    final _LineMetric metric = _detectMetric(normalized);

    if (metric == _LineMetric.unknown) {
      return;
    }

    final _LineDirection direction = _detectDirection(normalized);

    String? value;

    switch (metric) {
      case _LineMetric.speed:
        value = _extractSpeedValue(
          line,
          removeLabels: true,
        );
        break;

      case _LineMetric.snr:
      case _LineMetric.attenuation:
        value = _extractDecimalValue(
          line,
          removeLabels: true,
        );
        break;

      case _LineMetric.crc:
      case _LineMetric.es:
      case _LineMetric.ses:
        value = _extractIntegerValue(
          line,
          removeLabels: true,
        );
        break;

      case _LineMetric.unknown:
        break;
    }

    if (value == null || value.trim().isEmpty) {
      return;
    }

    _saveMetricValue(
      result: result,
      direction: direction,
      metric: metric,
      value: value.trim(),
    );
  }

  void _saveMetricValue({
    required Map<String, String> result,
    required _LineDirection direction,
    required _LineMetric metric,
    required String value,
  }) {
    final String cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      return;
    }

    switch (metric) {
      case _LineMetric.speed:
        if (direction == _LineDirection.downstream) {
          if (!result.containsKey('downstreamRate')) {
            result['downstreamRate'] = cleanValue;
          }
        } else if (direction == _LineDirection.upstream) {
          if (!result.containsKey('upstreamRate')) {
            result['upstreamRate'] = cleanValue;
          }
        } else {
          if (!result.containsKey('rate')) {
            result['rate'] = cleanValue;
          }
        }

        break;

      case _LineMetric.snr:
        if (direction == _LineDirection.downstream) {
          result['downstreamSnr'] = cleanValue;
        } else if (direction == _LineDirection.upstream) {
          result['upstreamSnr'] = cleanValue;
        } else {
          result['snr'] = cleanValue;
        }

        break;

      case _LineMetric.attenuation:
        if (direction == _LineDirection.downstream) {
          result['downstreamAttenuation'] = cleanValue;
        } else if (direction == _LineDirection.upstream) {
          result['upstreamAttenuation'] = cleanValue;
        } else {
          result['attenuation'] = cleanValue;
        }

        break;

      case _LineMetric.crc:
        if (direction == _LineDirection.downstream) {
          result['downstreamCrc'] = cleanValue;
        } else if (direction == _LineDirection.upstream) {
          result['upstreamCrc'] = cleanValue;
        } else {
          result['crc'] = cleanValue;
        }

        break;

      case _LineMetric.es:
        if (direction == _LineDirection.downstream) {
          result['downstreamEs'] = cleanValue;
        } else if (direction == _LineDirection.upstream) {
          result['upstreamEs'] = cleanValue;
        } else {
          result['es'] = cleanValue;
        }

        break;

      case _LineMetric.ses:
        if (direction == _LineDirection.downstream) {
          result['downstreamSes'] = cleanValue;
        } else if (direction == _LineDirection.upstream) {
          result['upstreamSes'] = cleanValue;
        } else {
          result['ses'] = cleanValue;
        }

        break;

      case _LineMetric.unknown:
        break;
    }
  }

  _LineDirection _detectDirection(
    String normalized,
  ) {
    final String value = normalized.toLowerCase();

    const List<String> downstreamWords = [
      'downstream',
      'downstreamrate',
      'downstreamspeed',
      'downstreamsnr',
      'downstreamattn',
      'downstreamattenuation',
      'downstream',
      'down',
      'download',
      'receiver',
      'receive',
      'received',
      'receiving',
      'rx',
      'ds',
      'dsrate',
      'dsspeed',
      'dsnrate',
      'dssnr',
      'dsmargin',
      'dsnoise',
      'dsattenuation',
      'dsattn',
      'downnoisemargin',
      'downsnr',
      'downattn',
      'downattenuation',
      'downrate',
      'downspeed',
      'downstreamstream',
      'downstreamdirection',
    ];

    for (final String word in downstreamWords) {
      if (value.contains(word)) {
        return _LineDirection.downstream;
      }
    }

    const List<String> upstreamWords = [
      'upstream',
      'upstreamrate',
      'upstreamspeed',
      'upstreamsnr',
      'upstreamattn',
      'upstreamattenuation',
      'up',
      'upload',
      'transmit',
      'transmitted',
      'transmission',
      'tx',
      'us',
      'usrate',
      'usspeed',
      'ussnr',
      'usmargin',
      'usnoise',
      'usattenuation',
      'usattn',
      'upnoisemargin',
      'upsnr',
      'upattn',
      'upattenuation',
      'uprate',
      'upspeed',
      'upstreamstream',
      'upstreamdirection',
    ];

    for (final String word in upstreamWords) {
      if (value.contains(word)) {
        return _LineDirection.upstream;
      }
    }

    return _LineDirection.unknown;
  }

  _LineMetric _detectMetric(
    String normalized,
  ) {
    final String value = normalized.toLowerCase();

    const List<String> sesWords = [
      'ses',
      'sescount',
      'seserror',
      'seserrors',
      'severelyerroredseconds',
      'severelyerroredsecond',
      'severelyerrored',
      'severelyerroredseconds',
    ];

    for (final String word in sesWords) {
      if (value == word || value.contains(word)) {
        return _LineMetric.ses;
      }
    }

    const List<String> crcWords = [
      'crc',
      'crcerr',
      'crcerror',
      'crcerrors',
      'crcfail',
      'crcfailed',
      'crcerrorcount',
      'cyclicredundancy',
      'cyclicredundancycheck',

      // مهم جداً لـ D-Link
      'error',
      'errors',
      'errorcount',
      'errorcounts',
      'err',
      'errs',
      'errcount',
      'errcounts',
      'fec',
      'fecerror',
      'fecerrors',
    ];

    for (final String word in crcWords) {
      if (value == word || value.contains(word)) {
        return _LineMetric.crc;
      }
    }

    const List<String> esWords = [
      'escount',
      'eserror',
      'eserrors',
      'errorseconds',
      'erroredseconds',
      'erroredsecond',
      'errorsecond',
      'erroredsec',
      'errorsec',
    ];

    for (final String word in esWords) {
      if (value.contains(word)) {
        return _LineMetric.es;
      }
    }

    if (value == 'es') {
      return _LineMetric.es;
    }

    const List<String> snrWords = [
      'snr',
      'snrmargin',
      'snrmargin',
      'noisemargin',
      'signalnoiseratio',
      'signaltonoiseratio',
      'signalnoise',
      'noiseratio',
      'noise',
      'snrmargen',
      'snrmargn',
      'snrmargin',
      'snrmarging',
      'snrmargin',
    ];

    for (final String word in snrWords) {
      if (value.contains(word)) {
        return _LineMetric.snr;
      }
    }

    const List<String> attenuationWords = [
      'attenuation',
      'attenuatio',
      'attenuttion',
      'attenution',
      'attentuation',
      'attn',
      'lineattenuation',
      'lineattn',
      'lineloss',
      'loss',
      'atten',
    ];

    for (final String word in attenuationWords) {
      if (value.contains(word)) {
        return _LineMetric.attenuation;
      }
    }

    const List<String> speedWords = [
      'rate',
      'speed',
      'datarate',
      'bitrate',
      'linerate',
      'linkrate',
      'linkspeed',
      'syncrate',
      'syncspeed',
      'synchspeed',
      'currentrate',
      'actualrate',
      'actualspeed',
      'curr',
      'kbps',
      'mbps',
      'gbps',
      'kbit',
      'mbit',
      'gbit',
      'kbits',
      'mbits',
      'gbits',
      'bandwidth',
    ];

    for (final String word in speedWords) {
      if (value.contains(word)) {
        return _LineMetric.speed;
      }
    }

    return _LineMetric.unknown;
  }

  String? _extractBestValue(
    String line,
    _LineMetric metric,
  ) {
    switch (metric) {
      case _LineMetric.speed:
        return _extractSpeedValue(line);

      case _LineMetric.snr:
        return _extractDecimalValue(line);

      case _LineMetric.attenuation:
        return _extractDecimalValue(line);

      case _LineMetric.crc:
        return _extractIntegerValue(line);

      case _LineMetric.es:
        return _extractIntegerValue(line);

      case _LineMetric.ses:
        return _extractIntegerValue(line);

      case _LineMetric.unknown:
        return null;
    }
  }

  String? _extractSpeedValue(
    String line, {
    bool removeLabels = false,
  }) {
    String value = line;

    if (removeLabels) {
      value = _removeStatisticLabels(value);
    }

    final RegExpMatch? withUnit = RegExp(
      r'(?<![\w.])'
      r'(\d+(?:\.\d+)?)'
      r'\s*'
      r'(kbps|mbps|gbps|'
      r'kbit/s|mbit/s|gbit/s|'
      r'kbit|mbit|gbit|'
      r'kbits|mbits|gbits|'
      r'bit/s)'
      r'(?!\w)',
      caseSensitive: false,
    ).firstMatch(value);

    if (withUnit != null) {
      final String number = withUnit.group(1)!;

      final String unit = withUnit.group(2)!.toLowerCase();

      return '$number $unit';
    }

    return _extractFirstNumber(value);
  }

  String? _extractDecimalValue(
    String line, {
    bool removeLabels = false,
  }) {
    String value = line;

    if (removeLabels) {
      value = _removeStatisticLabels(
        value,
      );
    }

    final RegExpMatch? match = RegExp(
      r'(?<![\w.])'
      r'(-?\d+(?:\.\d+)?)'
      r'(?![\w.])',
    ).firstMatch(value);

    return match?.group(1);
  }

  String? _extractIntegerValue(
    String line, {
    bool removeLabels = false,
  }) {
    String value = line;

    if (removeLabels) {
      value = _removeStatisticLabels(
        value,
      );
    }

    final RegExpMatch? match = RegExp(
      r'(?<![\w.])'
      r'(\d+)'
      r'(?![\w.])',
    ).firstMatch(value);

    return match?.group(1);
  }

  String? _extractFirstNumber(
    String value,
  ) {
    final RegExpMatch? match = RegExp(
      r'(-?\d+(?:\.\d+)?)',
    ).firstMatch(value);

    return match?.group(1);
  }

  String _removeStatisticLabels(
    String value,
  ) {
    String result = value;

    final List<String> labels = [
      'down stream',
      'up stream',
      'downstream',
      'upstream',
      'download',
      'upload',
      'snr margin',
      'snr margen',
      'snr margn',
      'noise margin',
      'snr',
      'attenuation',
      'attenuatio',
      'attenuttion',
      'attenution',
      'attentuation',
      'attn',
      'line attenuation',
      'line attn',
      'rate',
      'speed',
      'data rate',
      'bit rate',
      'line rate',
      'link rate',
      'link speed',
      'sync rate',
      'sync speed',
      'current rate',
      'actual rate',
      'actual speed',
      'crc',
      'crc error',
      'crc errors',
      'error',
      'errors',
      'error count',
      'error counts',
      'es',
      'ses',
      'error seconds',
      'errored seconds',
      'severely errored seconds',
    ];

    for (final String label in labels) {
      result = result.replaceAll(
        RegExp(
          RegExp.escape(label),
          caseSensitive: false,
        ),
        ' ',
      );
    }

    return result.trim();
  }

  bool _isStatusKey(
    String normalized,
  ) {
    const List<String> statusWords = [
      'status',
      'state',
      'linestatus',
      'dslstatus',
      'adslstatus',
      'vdslstatus',
      'linkstatus',
      'connectionstatus',
      'connectionstate',
      'dslstate',
      'adslstate',
      'vdslstate',
      'linkstate',
    ];

    for (final String word in statusWords) {
      if (normalized == word || normalized.contains(word)) {
        return true;
      }
    }

    return false;
  }

  String? _extractStatusValue(
    String line,
  ) {
    final RegExpMatch? equalsMatch = RegExp(
      r'^[^=:]+[:=]\s*(.+)$',
      caseSensitive: false,
    ).firstMatch(line);

    if (equalsMatch != null) {
      return equalsMatch.group(1)?.trim();
    }

    final RegExpMatch? match = RegExp(
      r'^(?:line\s*)?'
      r'(?:status|state)'
      r'\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(line);

    if (match != null) {
      return match.group(1)?.trim();
    }

    const List<String> statuses = [
      'showtime',
      'up',
      'down',
      'uping',
      'downing',
      'connected',
      'disconnected',
      'training',
      'handshake',
      'initializing',
      'idle',
      'ready',
      'failed',
      'error',
    ];

    final String lower = line.toLowerCase();

    for (final String status in statuses) {
      if (lower.contains(status)) {
        return status;
      }
    }

    return null;
  }

  String _cleanStatusValue(
    String value,
  ) {
    String result = value.trim();

    result = result.replaceAll(
      RegExp(r'^[=:]\s*'),
      '',
    );

    return result.trim();
  }

  String _normalize(
    String value,
  ) {
    return value.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
  }

  bool _isCommandOrPrompt(
    String line,
  ) {
    final String trimmed = line.trim();

    if (trimmed.isEmpty) {
      return true;
    }

    final String normalized = _normalize(trimmed);

    const List<String> ignoredCommands = [
      'showadsl',
      'showdsl',
      'showvdsl',
      'showstatus',
      'ap',
    ];

    for (final String command in ignoredCommands) {
      if (normalized == command) {
        return true;
      }
    }

    if (trimmed == '#' ||
        trimmed == '>' ||
        trimmed.endsWith('#') ||
        trimmed.endsWith('>')) {
      return true;
    }

    if (RegExp(
      r'^[A-Za-z0-9_.\-]+[#>]$',
    ).hasMatch(trimmed)) {
      return true;
    }

    return false;
  }

  bool _isSuccessfulPasswordResponse(
    String output,
  ) {
    final String value = output.trim().toLowerCase();

    if (value.isEmpty) {
      return true;
    }

    const List<String> errorWords = [
      'error',
      'failed',
      'failure',
      'invalid',
      'unknown command',
      'unknowncommand',
      'not found',
      'notfound',
      'syntax error',
      'syntaxerror',
      'cannot',
      'unable',
      'denied',
      'reject',
      'rejected',
      'permission denied',
      'invalid argument',
      'invalid parameter',
    ];

    for (final String word in errorWords) {
      if (value.contains(word)) {
        return false;
      }
    }

    return true;
  }

  String _extractCommandError(
    String output,
  ) {
    final String value = output.trim();

    if (value.isEmpty) {
      return 'لم يتم الحصول على استجابة من الراوتر';
    }

    return 'الراوتر رفض تنفيذ الأمر:\n'
        '${_sanitizeOutput(value)}';
  }

  String _sanitizeOutput(
    String output,
  ) {
    return output.replaceAll(
      RegExp(
        r'(wlctl\s+set\s+(?:2g|5g)\s+--sec\s+psk\s+wpa2\s+aes\s+)\S+',
        caseSensitive: false,
      ),
      r'$1********',
    );
  }

  String _hidePassword(
    String command,
  ) {
    final String placeholderHidden = command.replaceAll(
      RegExp(
        r'\{password\}',
        caseSensitive: false,
      ),
      '********',
    );

    final RegExp regex = RegExp(
      r'(wlctl\s+set\s+(?:2g|5g)\s+'
      r'--sec\s+psk\s+wpa2\s+aes\s+)\S+',
      caseSensitive: false,
    );

    return placeholderHidden.replaceAllMapped(
      regex,
      (Match match) {
        return '${match.group(1)}********';
      },
    );
  }

  String _getFriendlyTelnetError(
    Object error, {
    required String defaultMessage,
  }) {
    final String value = error.toString().toLowerCase();

    if (value.contains('timeout')) {
      return 'انتهت مهلة الاتصال بالراوتر';
    }

    if (value.contains('socket')) {
      return 'حدث خطأ في اتصال الشبكة بالراوتر';
    }

    if (value.contains('connection')) {
      return 'انقطع الاتصال بالراوتر';
    }

    if (value.contains('closed')) {
      return 'تم إغلاق اتصال Telnet بالراوتر';
    }

    return defaultMessage;
  }

  void clearPasswordMessages() {
    if (_isDisposed) {
      return;
    }

    _passwordError = null;
    _passwordSuccess = null;

    _safeNotify();
  }

  Future<bool> showLineStatisticsNow() async {
    return loadLineStatistics();
  }

  void hideLineStatistics() {
    if (_isDisposed) {
      return;
    }

    _showLineStatistics = false;

    _safeNotify();
  }

  void clearLineStatistics({
    bool notify = true,
  }) {
    _lineStatisticsOutput = null;
    _lineStatisticsError = null;
    _lineStatisticsValues = {};
    _showLineStatistics = false;
    _isLoadingLineStatistics = false;

    if (notify) {
      _safeNotify();
    }
  }

  Future<void> disconnect() async {
    if (_isDisposed) {
      return;
    }
    try {
      await telnetService.disconnect();
    } catch (e) {
      debugPrint(
        '[RouterManagementController] '
        'DISCONNECT ERROR: $e',
      );
    }
  }

  void _printCommands() {
    if (_isDisposed) {
      return;
    }

    debugPrint(
      'Success: ${settingController.response?.success}',
    );

    debugPrint(
      'Message: ${settingController.response?.message}',
    );

    debugPrint(
      'Categories Count: '
      '${settingController.commands.length}',
    );

    for (final entry in settingController.commands.entries) {
      final String categoryName = entry.key;

      final RouterCommandCategory category = entry.value;

      debugPrint(
        'CATEGORY: $categoryName',
      );

      debugPrint(
        'Commands Count: '
        '${category.commands.length}',
      );

      for (final RouterCommand command in category.commands) {
        debugPrint(
          'Command ID: ${command.id}',
        );

        debugPrint(
          'Command: '
          '${_hidePassword(command.command)}',
        );
      }
    }
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }

    debugPrint(
      '[RouterManagementController] DISPOSE',
    );

    _isDisposed = true;

    if (_ownsSettingController) {
      settingController.dispose();
    }

    super.dispose();
  }
}

enum _LineDirection {
  downstream,
  upstream,
  unknown,
}

enum _LineMetric {
  speed,
  snr,
  attenuation,
  crc,
  es,
  ses,
  unknown,
}
