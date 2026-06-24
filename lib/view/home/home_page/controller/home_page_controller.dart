import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:omniya/const/url.dart';
import 'package:omniya/l10n/app_localizations.dart';
import 'package:omniya/model/user_model.dart';
import 'package:omniya/view/auth/services/api_client.dart';

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

  UserModel? user;
  final String apiUserDetails = "${AppApi.url}${AppApi.userdetails}";
  final String apiorderstempextend = "${AppApi.url}${AppApi.orderstempextend}";
  HomeState state = HomeState.loading;
  String errorMessage = '';

  void _updateState(HomeState newState, {String error = ''}) {
    state = newState;
    errorMessage = error;
    notifyListeners();
  }

  Future<void> getUserDetails(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      _updateState(HomeState.loading);

      final response = await apiClient
          .get(Uri.parse(apiUserDetails))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        user = UserModel.fromJson(data);
        _updateState(HomeState.success);
      } else if (response.statusCode >= 500) {
        _updateState(
          HomeState.serverError,
          error: l10n.server_error_message,
        );
      } else {
        _updateState(
          HomeState.unexpectedError,
          error: "${l10n.failed_fetch_data}${response.statusCode}",
        );
      }
    } on SocketException catch (e) {
      debugPrint(' [Network Error]: $e');
      _updateState(
        HomeState.noInternet,
        error: l10n.no_internet_connection,
      );
    } catch (e) {
      debugPrint(' [Unknown Error]: $e');

      if (e.toString().contains("SESSION_EXPIRED")) {
        _updateState(
          HomeState.unauthorized,
          error: l10n.session_expired,
        );
      } else {
        _updateState(
          HomeState.unexpectedError,
          error: l10n.unexpected_error,
        );
      }
    }
  }

  ///////////////////////
  //////////////////////
  //////////////////////
  Future<String?> extendSubscription({
    required int days,
    required BuildContext context,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      _updateState(HomeState.loading);

      final url = Uri.parse(apiorderstempextend);

      final body = {
        "days": days,
        "is_mobile": 1,
      };

      final response = await apiClient.post(url, body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await getUserDetails(context);
        return "success";
      } else {
        return data["error"]?.toString() ??
            data["message"]?.toString() ??
            l10n.unexpected_error;
      }
    } catch (e) {
      return l10n.unexpected_error;
    }
  }
}
