import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omniya/core/const/url.dart';
import 'package:omniya/core/l10n/app_localizations.dart';
import 'package:omniya/core/services/auth_storage.dart';
import 'package:omniya/core/services/api_client.dart';
import 'package:omniya/core/services/api_error_handler.dart';
import 'package:omniya/model/user_model.dart';

enum HomeState {
  loading,
  success,
  noInternet,
  serverError,
  unexpectedError,
  unauthorized,
}

class HomePageController with ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  bool _isFetching = false;
  UserModel? user;

  final String apiUserDetails = "${AppApi.url}${AppApi.userdetails}";
  final String apiorderstempextend = "${AppApi.url}${AppApi.orderstempextend}";
  HomeState state = HomeState.loading;
  String errorMessage = '';
  final AuthStorage storage = AuthStorage();
  String? name;

  void _updateState(
    HomeState newState, {
    String error = '',
  }) {
    state = newState;
    errorMessage = error;

    notifyListeners();
  }

  Future<void> getUserDetails(
    BuildContext context,
  ) async {
    if (_isFetching) return;

    _isFetching = true;

    final l10n = AppLocalizations.of(context)!;

    try {
      _updateState(
        HomeState.loading,
      );

      final response = await apiClient
          .get(
            Uri.parse(apiUserDetails),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        "GET USER DETAILS STATUS => ${response.statusCode}",
      );

      debugPrint(
        "GET USER DETAILS BODY => ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        user = UserModel.fromJson(
          data,
        );

        await AuthStorage().saveUsername(
          user!.username,
        );

        _updateState(
          HomeState.success,
        );

        return;
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(
          response.body,
        );

        user = UserModel.fromJson(
          data,
        );

        await AuthStorage().saveUsername(
          user!.username,
        );

        _updateState(
          HomeState.success,
        );

        return;
      }

      if (response.statusCode == 401) {
        Map<String, dynamic>? data;

        try {
          final decoded = jsonDecode(
            response.body,
          );

          if (decoded is Map<String, dynamic>) {
            data = decoded;
          }
        } catch (_) {}

        _updateState(
          HomeState.unauthorized,
          error: data?["error"]?.toString() ??
              data?["message"]?.toString() ??
              l10n.login_failed,
        );

        return;
      }

      if (response.statusCode == 404) {
        _updateState(
          HomeState.noInternet,
          error: l10n.connection_error,
        );

        return;
      }

      _updateState(
        HomeState.unexpectedError,
        error: ApiErrorHandler.getUnhandledErrorMessage(
          context: context,
        ),
      );
    } catch (e) {
      debugPrint(
        "GET USER DETAILS ERROR => $e",
      );

      _updateState(
        HomeState.unexpectedError,
        error: l10n.unexpected_error,
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<String?> extendSubscription({
    required int days,
    required BuildContext context,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      _updateState(
        HomeState.loading,
      );

      final url = Uri.parse(
        apiorderstempextend,
      );

      final body = {
        "days": days,
        "is_mobile": 1,
      };

      final response = await apiClient.post(
        url,
        body,
      );

      debugPrint(
        "EXTEND SUBSCRIPTION STATUS => ${response.statusCode}",
      );

      debugPrint(
        "EXTEND SUBSCRIPTION BODY => ${response.body}",
      );

      if (response.statusCode == 200) {
        await getUserDetails(
          context,
        );

        return "success";
      }

      if (response.statusCode == 201) {
        await getUserDetails(
          context,
        );

        return "success";
      }

      if (response.statusCode == 401) {
        Map<String, dynamic>? data;

        try {
          final decoded = jsonDecode(
            response.body,
          );

          if (decoded is Map<String, dynamic>) {
            data = decoded;
          }
        } catch (_) {}

        return data?["error"]?.toString() ??
            data?["message"]?.toString() ??
            l10n.login_failed;
      }

      if (response.statusCode == 404) {
        return l10n.connection_error;
      }

      return ApiErrorHandler.getUnhandledErrorMessage(
        context: context,
      );
    } catch (e) {
      debugPrint(
        "EXTEND SUBSCRIPTION ERROR => $e",
      );

      return l10n.unexpected_error;
    }
  }
}
