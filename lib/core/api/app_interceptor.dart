import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final void Function() onUnauthorized;

  AppInterceptor({
    required SharedPreferences prefs,
    required this.onUnauthorized,
  }) : _prefs = prefs;

  String? get _token => _prefs.getString('auth_token');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    log('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );

    if (err.response?.statusCode == 401) {
      _prefs.remove('auth_token');
      onUnauthorized();
    }

    handler.next(err);
  }
}
