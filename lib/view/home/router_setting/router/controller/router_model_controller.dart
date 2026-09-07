import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/core/services/api_client.dart';

import 'package:omniya/model/setting/router_model.dart';
import 'package:omniya/view/home/router_setting/router_login/controller/router_controller.dart';

class RouterModelController extends ChangeNotifier {
  final ApiClient apiClient;
  final RouterController routerController;

  late final AppLocalizations l10;

  RouterModelController({
    ApiClient? apiClient,
    RouterController? routerController,
  })  : apiClient = apiClient ?? ApiClient(),
        routerController = routerController ?? RouterController();

  String? _gateway;
  String? get gateway => _gateway;
  List<RouterBrand> _brands = [];
  List<RouterBrand> get brands => List.unmodifiable(_brands);
  List<RouterModel> _routers = [];

  List<RouterModel> get routers => List.unmodifiable(_routers);
  bool _isInitializing = false;
  bool get isInitializing => _isInitializing;
  bool _isLoadingBrands = false;
  bool get isLoadingBrands => _isLoadingBrands;
  bool _isLoadingRouters = false;
  bool get isLoadingRouters => _isLoadingRouters;
  bool _initialized = false;
  bool get initialized => _initialized;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError =>
      _errorMessage != null && _errorMessage!.trim().isNotEmpty;

  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    if (_isInitializing) {
      return false;
    }

    _isInitializing = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final String? gateway = await routerController.getGateway();

      if (gateway == null || gateway.trim().isEmpty) {
        _setError(
          '${l10.router_gateway_not_found}\n'
          '${l10.router_connection_help}',
        );

        debugPrint(
          '[RouterModelController] ERROR initialize: Gateway not found',
        );

        return false;
      }

      _gateway = gateway.trim();

      debugPrint(
        '[RouterModelController] Gateway received: $_gateway',
      );

      final bool brandsSuccess = await getBrands(
        notify: false,
      );

      if (!brandsSuccess) {
        _setError(
          routerController.errorMessage ?? l10.router_brands_load_failed,
        );

        debugPrint(
          '[RouterModelController] ERROR initialize: '
          'Failed to load brands',
        );

        return false;
      }

      _initialized = true;
      _errorMessage = null;

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterModelController] ERROR initialize: $e',
      );

      debugPrint(
        '[RouterModelController] STACK TRACE initialize:\n$stackTrace',
      );

      _setError(
        _friendlyError(
          e,
          fallback: l10.router_prepare_settings,
        ),
      );

      return false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> refreshGateway() async {
    try {
      final String? gateway = await routerController.getGateway();

      if (gateway == null || gateway.trim().isEmpty) {
        _setError(
          '${l10.router_gateway_not_found}\n'
          '${l10.router_connection_help}',
        );

        debugPrint(
          '[RouterModelController] ERROR refreshGateway: '
          'Gateway not found',
        );

        return false;
      }

      _gateway = gateway.trim();

      _errorMessage = null;

      debugPrint(
        '[RouterModelController] Gateway received: $_gateway',
      );

      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterModelController] ERROR refreshGateway: $e',
      );

      debugPrint(
        '[RouterModelController] STACK TRACE refreshGateway:\n$stackTrace',
      );

      _setError(
        _friendlyError(
          e,
          fallback: l10.router_gateway_not_found,
        ),
      );

      return false;
    }
  }

  Future<bool> getBrands({
    bool notify = true,
  }) async {
    if (_isLoadingBrands) {
      return false;
    }

    _isLoadingBrands = true;
    _errorMessage = null;

    if (notify) {
      notifyListeners();
    }

    try {
      final bool success = await routerController.getBrands();

      if (!success) {
        _errorMessage =
            routerController.errorMessage ?? l10.router_brands_load_failed;

        debugPrint(
          '[RouterModelController] ERROR getBrands: '
          '${routerController.errorMessage}',
        );

        return false;
      }

      _brands = List<RouterBrand>.from(
        routerController.brands,
      );

      debugPrint(
        '[RouterModelController] Server response: '
        'Brands loaded successfully',
      );

      debugPrint(
        '[RouterModelController] Brands received: ${_brands.length}',
      );

      if (_brands.isNotEmpty) {
        debugPrint(
          '[RouterModelController] Brands data: '
          '${_brands.map((brand) => {
                'id': brand.id,
                'name': brand.name,
                'slug': brand.slug,
              }).toList()}',
        );
      }

      _errorMessage = null;

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterModelController] ERROR getBrands: $e',
      );

      debugPrint(
        '[RouterModelController] STACK TRACE getBrands:\n$stackTrace',
      );

      _errorMessage = _friendlyError(
        e,
        fallback: l10.router_brands_load_failed,
      );

      return false;
    } finally {
      _isLoadingBrands = false;

      if (notify) {
        notifyListeners();
      }
    }
  }

  Future<bool> getRoutersByBrand(
    RouterBrand brand,
  ) async {
    if (_isLoadingRouters) {
      return false;
    }

    _isLoadingRouters = true;
    _errorMessage = null;

    _routers = [];

    notifyListeners();

    try {
      debugPrint(
        '[RouterModelController] Loading routers for brand: '
        '${brand.name} (${brand.slug})',
      );

      final bool success = await routerController.getRoutersByBrand(
        brand,
      );

      if (!success) {
        _errorMessage =
            routerController.errorMessage ?? l10.router_models_unavailable;

        debugPrint(
          '[RouterModelController] ERROR getRoutersByBrand: '
          '${routerController.errorMessage}',
        );

        return false;
      }

      _routers = List<RouterModel>.from(
        routerController.routers,
      );

      debugPrint(
        '[RouterModelController] Server response: '
        'Routers loaded successfully',
      );

      debugPrint(
        '[RouterModelController] Routers received: ${_routers.length}',
      );
      _errorMessage = null;

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterModelController] ERROR getRoutersByBrand: $e',
      );

      debugPrint(
        '[RouterModelController] STACK TRACE getRoutersByBrand:\n$stackTrace',
      );

      _errorMessage = _friendlyError(
        e,
        fallback: l10.router_models_unavailable,
      );

      return false;
    } finally {
      _isLoadingRouters = false;

      notifyListeners();
    }
  }

  Future<bool> refresh() async {
    _errorMessage = null;

    try {
      final bool gatewaySuccess = await refreshGateway();

      if (!gatewaySuccess) {
        return false;
      }

      final bool brandsSuccess = await getBrands();

      if (!brandsSuccess) {
        return false;
      }

      _initialized = true;

      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        '[RouterModelController] ERROR refresh: $e',
      );

      debugPrint(
        '[RouterModelController] STACK TRACE refresh:\n$stackTrace',
      );

      _errorMessage = _friendlyError(
        e,
        fallback: l10.router_unable_load_data,
      );

      notifyListeners();

      return false;
    }
  }

  Future<bool> retry() async {
    _initialized = false;
    _gateway = null;
    _brands = [];
    _routers = [];
    _errorMessage = null;

    notifyListeners();

    debugPrint(
      '[RouterModelController] Retrying router initialization...',
    );

    return initialize();
  }

  void clearRouters() {
    _routers = [];
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  String _friendlyError(
    Object error, {
    required String fallback,
  }) {
    final String message = error.toString();

    debugPrint(
      '[RouterModelController] Raw error: $message',
    );

    if (message.contains('SESSION_EXPIRED')) {
      return l10.session_expired;
    }

    if (message.contains('SocketException')) {
      return l10.no_internet_connection;
    }

    if (message.contains('TimeoutException')) {
      return l10.router_connection_timeout;
    }

    if (message.contains('FormatException')) {
      return l10.router_invalid_server_response;
    }

    return fallback;
  }

  @override
  void dispose() {
    routerController.dispose();

    super.dispose();
  }
}
