import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:omniya/const/url.dart';
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

  HomeState state = HomeState.loading;
  String errorMessage = '';

  void _updateState(HomeState newState, {String error = ''}) {
    state = newState;
    errorMessage = error;
    notifyListeners();
  }

  Future<void> getUserDetails() async {
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
          error: 'حدث خطأ في السيرفر. يرجى المحاولة لاحقاً.',
        );
      } else {
        _updateState(
          HomeState.unexpectedError,
          error: 'فشل جلب البيانات. كود الخطأ: ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      debugPrint(' [Network Error]: $e');
      _updateState(
        HomeState.noInternet,
        error: 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.',
      );
    } catch (e) {
      debugPrint(' [Unknown Error]: $e');

      if (e.toString().contains("SESSION_EXPIRED")) {
        _updateState(
          HomeState.unauthorized,
          error: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.',
        );
      } else {
        _updateState(HomeState.unexpectedError, error: 'حدث خطأ غير متوقع.');
      }
    }
  }
}
