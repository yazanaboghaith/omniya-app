import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:omniya/core/const/app_notifier.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/core/services/api_error_handler.dart';
import 'package:omniya/core/services/auth_storage.dart';
import 'package:omniya/model/setting/router_model.dart';

class RouterController extends ChangeNotifier {
  final AuthStorage _authStorage = AuthStorage();

  String? _token;

  String? get token => _token;

  bool isLoadingBrands = false;
  bool isLoadingModels = false;
  bool isLoadingCommands = false;
  bool isLoadingToken = false;

  String? errorMessage;

  List<RouterBrand> brands = [];
  List<RouterModel> routers = [];

  RouterBrand? selectedBrand;
  RouterModel? selectedRouter;

  Future<bool> initialize({
    BuildContext? context,
  }) async {
    debugPrint('[RouterController] INITIALIZE');

    isLoadingToken = true;
    errorMessage = null;

    notifyListeners();

    try {
      final savedToken = await _authStorage.getToken();

      if (savedToken == null || savedToken.trim().isEmpty) {
        debugPrint('[RouterController] Token not found');

        _token = null;

        _setError(
          context: context,
          message: context != null
              ? AppLocalizations.of(context)!.router_login_token_not_found
              : 'لم يتم العثور على رمز الدخول',
        );

        return false;
      }

      _token = savedToken.trim();

      debugPrint('[RouterController] Token loaded');

      return true;
    } catch (e) {
      debugPrint('[RouterController] Token load failed: $e');

      _token = null;

      _setError(
        context: context,
        message: context != null
            ? AppLocalizations.of(context)!.router_login_data_read_failed
            : 'تعذر قراءة بيانات تسجيل الدخول',
      );

      return false;
    } finally {
      isLoadingToken = false;
      notifyListeners();
    }
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (_token != null && _token!.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_token!.trim()}';
    }

    return headers;
  }

  Uri _buildUrl(String path) {
    final baseUrl = AppApi.url.endsWith('/') ? AppApi.url : '${AppApi.url}/';

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse('$baseUrl$normalizedPath');
  }

  Future<bool> _ensureToken({
    BuildContext? context,
  }) async {
    if (_token != null && _token!.trim().isNotEmpty) {
      return true;
    }

    return initialize(
      context: context,
    );
  }

  String? _getServerMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        final possibleKeys = [
          'error',
          'message',
          'msg',
        ];

        for (final key in possibleKeys) {
          final value = decoded[key];

          if (value != null) {
            final message = value.toString().trim();

            if (message.isNotEmpty) {
              return message;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[RouterController] Server message parse failed');
    }

    return null;
  }

  void _setError({
    required BuildContext? context,
    required String message,
  }) {
    errorMessage = message;

    debugPrint('[RouterController] ERROR: $message');

    if (context == null) {
      notifyListeners();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }

      AppNotifier.instance.error(
        context,
        message,
      );
    });

    notifyListeners();
  }

  void _handleResponseError({
    required http.Response response,
    required BuildContext? context,
    required String defaultMessage,
  }) {
    final serverMessage = _getServerMessage(response.body);

    if (serverMessage != null && serverMessage.isNotEmpty) {
      _setError(
        context: context,
        message: serverMessage,
      );
      return;
    }

    if (context != null) {
      final message = ApiErrorHandler.getUnhandledErrorMessage(
        context: context,
      );

      _setError(
        context: context,
        message: message,
      );

      return;
    }

    _setError(
      context: null,
      message: defaultMessage,
    );
  }

  String _getLocalizedNetworkError(
    BuildContext? context,
    String errorText,
  ) {
    if (context == null) {
      if (errorText.contains('failed host lookup') ||
          errorText.contains(
            'no address associated with hostname',
          ) ||
          errorText.contains('network is unreachable') ||
          errorText.contains('network unreachable')) {
        return 'لا يوجد اتصال بالإنترنت';
      }

      if (errorText.contains('connection refused')) {
        return 'تم رفض الاتصال';
      }

      if (errorText.contains('timed out') || errorText.contains('timeout')) {
        return 'انتهت مهلة الاتصال';
      }

      return 'حدث خطأ أثناء الاتصال';
    }

    final l10n = AppLocalizations.of(context)!;

    if (errorText.contains('failed host lookup') ||
        errorText.contains(
          'no address associated with hostname',
        ) ||
        errorText.contains('network is unreachable') ||
        errorText.contains('network unreachable') ||
        errorText.contains('connection reset') ||
        errorText.contains('connection aborted')) {
      return l10n.no_internet_connection;
    }

    if (errorText.contains('connection refused')) {
      return l10n.router_connection_refused;
    }

    if (errorText.contains('timed out') || errorText.contains('timeout')) {
      return l10n.router_connection_timeout;
    }

    return l10n.router_unknown_error;
  }

  Future<bool> getBrands({
    BuildContext? context,
  }) async {
    debugPrint('[RouterController] GET BRANDS');

    isLoadingBrands = true;
    errorMessage = null;

    notifyListeners();

    try {
      final hasToken = await _ensureToken(
        context: context,
      );

      if (!hasToken) {
        return false;
      }

      final url = _buildUrl(
        AppApi.router,
      );

      final response = await http.get(
        url,
        headers: _headers,
      );

      debugPrint(
        '[RouterController] GET BRANDS STATUS: '
        '${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(
          response.body,
        );

        if (decoded is! Map<String, dynamic>) {
          _setError(
            context: context,
            message: context != null
                ? AppLocalizations.of(context)!.router_server_response_invalid
                : 'استجابة غير صحيحة من الخادم',
          );

          return false;
        }

        if (decoded['success'] != true) {
          final serverMessage = decoded['message']?.toString().trim();

          _setError(
            context: context,
            message: serverMessage != null && serverMessage.isNotEmpty
                ? serverMessage
                : context != null
                    ? AppLocalizations.of(context)!.router_brands_load_failed
                    : 'فشل جلب شركات الراوتر',
          );

          return false;
        }

        final dynamic data = decoded['data'];

        if (data is! List) {
          _setError(
            context: context,
            message: context != null
                ? AppLocalizations.of(context)!.router_brands_data_invalid
                : 'بيانات شركات الراوتر غير صحيحة',
          );

          return false;
        }

        brands = data
            .whereType<Map>()
            .map(
              (item) => RouterBrand.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        debugPrint(
          '[RouterController] BRANDS LOADED: ${brands.length}',
        );

        return true;
      }

      _handleResponseError(
        response: response,
        context: context,
        defaultMessage: context != null
            ? AppLocalizations.of(context)!.router_brands_load_failed
            : 'فشل جلب شركات الراوتر',
      );

      return false;
    } catch (e) {
      debugPrint(
        '[RouterController] GET BRANDS ERROR: $e',
      );

      final message = _getLocalizedNetworkError(
        context,
        e.toString().toLowerCase(),
      );

      _setError(
        context: context,
        message: message,
      );

      return false;
    } finally {
      isLoadingBrands = false;
      notifyListeners();
    }
  }

  static const MethodChannel _routerGatewayChannel =
      MethodChannel('router_gateway');

  Future<String?> getGateway({
    BuildContext? context,
  }) async {
    debugPrint('[RouterController] GET GATEWAY');

    try {
      final dynamic result = await _routerGatewayChannel.invokeMethod(
        'getNetworkInfo',
      );

      if (result == null) {
        _setError(
          context: context,
          message: context != null
              ? AppLocalizations.of(context)!.router_gateway_not_found
              : 'تعذر العثور على الراوتر',
        );

        return null;
      }

      if (result is Map) {
        final dynamic gatewayValue = result['gateway'];

        if (gatewayValue == null) {
          _setError(
            context: context,
            message: context != null
                ? AppLocalizations.of(context)!.router_gateway_not_found
                : 'تعذر العثور على الراوتر',
          );

          return null;
        }

        final gateway = gatewayValue.toString().trim();

        if (gateway.isEmpty) {
          _setError(
            context: context,
            message: context != null
                ? AppLocalizations.of(context)!.router_gateway_not_found
                : 'تعذر العثور على الراوتر',
          );

          return null;
        }

        debugPrint(
          '[RouterController] GATEWAY: $gateway',
        );

        return gateway;
      }

      if (result is String) {
        final gateway = result.trim();

        if (gateway.isEmpty) {
          _setError(
            context: context,
            message: context != null
                ? AppLocalizations.of(context)!.router_gateway_not_found
                : 'تعذر العثور على الراوتر',
          );

          return null;
        }

        debugPrint(
          '[RouterController] GATEWAY: $gateway',
        );

        return gateway;
      }

      _setError(
        context: context,
        message: context != null
            ? AppLocalizations.of(context)!.router_gateway_not_found
            : 'تعذر العثور على الراوتر',
      );

      return null;
    } on PlatformException catch (e) {
      debugPrint(
        '[RouterController] GATEWAY PLATFORM ERROR: '
        '${e.code}',
      );

      _setError(
        context: context,
        message: context != null
            ? AppLocalizations.of(context)!.router_gateway_not_found
            : 'تعذر العثور على الراوتر',
      );

      return null;
    } catch (e) {
      debugPrint(
        '[RouterController] GET GATEWAY ERROR: $e',
      );

      _setError(
        context: context,
        message: context != null
            ? AppLocalizations.of(context)!.router_unknown_error
            : 'حدث خطأ أثناء الاتصال',
      );

      return null;
    }
  }

  Future<bool> getRoutersByBrand(
    RouterBrand brand, {
    BuildContext? context,
  }) async {
    debugPrint(
      '[RouterController] GET ROUTERS: ${brand.name}',
    );

    isLoadingModels = true;
    errorMessage = null;

    selectedBrand = brand;
    selectedRouter = null;
    routers = [];

    notifyListeners();

    try {
      final hasToken = await _ensureToken(
        context: context,
      );

      if (!hasToken) {
        return false;
      }

      final url = _buildUrl(
        '${AppApi.routerbrand}/${brand.slug}',
      );

      debugPrint(
        '[RouterController] GET ROUTERS URL: $url',
      );

      final response = await http.get(
        url,
        headers: _headers,
      );

      debugPrint(
        '[RouterController] GET ROUTERS STATUS: '
        '${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          _setError(
            context: context,
            message: context != null
                ? AppLocalizations.of(context)!.router_server_response_invalid
                : 'استجابة غير صحيحة من الخادم',
          );

          return false;
        }

        if (decoded['success'] != true) {
          final serverMessage = decoded['message']?.toString().trim();

          _setError(
            context: context,
            message: serverMessage != null && serverMessage.isNotEmpty
                ? serverMessage
                : context != null
                    ? AppLocalizations.of(context)!.router_models_load_failed
                    : 'فشل جلب موديلات الراوتر',
          );

          return false;
        }

        final dynamic data = decoded['data'];

        if (data is! Map) {
          _setError(
            context: context,
            message: context != null
                ? AppLocalizations.of(context)!.router_models_data_invalid
                : 'بيانات الموديلات غير صحيحة',
          );

          return false;
        }

        final result = RouterModelsResponse.fromJson(
          Map<String, dynamic>.from(data),
        );

        routers = result.routers;

        debugPrint(
          '[RouterController] ROUTERS LOADED: '
          '${routers.length}',
        );

        return true;
      }

      _handleResponseError(
        response: response,
        context: context,
        defaultMessage: context != null
            ? AppLocalizations.of(context)!.router_models_load_failed
            : 'فشل جلب موديلات الراوتر',
      );

      return false;
    } catch (e) {
      debugPrint(
        '[RouterController] GET ROUTERS ERROR: $e',
      );

      final message = _getLocalizedNetworkError(
        context,
        e.toString().toLowerCase(),
      );

      _setError(
        context: context,
        message: message,
      );

      return false;
    } finally {
      isLoadingModels = false;
      notifyListeners();

      debugPrint(
        '[RouterController] GET ROUTERS FINISHED',
      );
    }
  }

  void selectRouter(
    RouterModel router,
  ) {
    selectedRouter = router;

    notifyListeners();
  }

  void clear() {
    debugPrint('[RouterController] CLEAR');

    brands = [];
    routers = [];

    selectedBrand = null;
    selectedRouter = null;

    errorMessage = null;

    isLoadingBrands = false;
    isLoadingModels = false;
    isLoadingCommands = false;
    isLoadingToken = false;

    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('[RouterController] DISPOSE');

    super.dispose();
  }
}
