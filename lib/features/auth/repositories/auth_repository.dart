import 'package:dio/dio.dart';

import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/auth/models/auth_exception.dart';
import 'package:cdegad_kp/features/auth/models/auth_response_model.dart';
import 'package:cdegad_kp/features/auth/models/dashboard_login_model.dart';
import 'package:cdegad_kp/features/auth/models/dashboard_signup_model.dart';
import 'package:cdegad_kp/features/auth/models/employee_login_model.dart';
import 'package:cdegad_kp/features/auth/models/employee_signup_model.dart';
import 'package:cdegad_kp/features/auth/models/mobile_signup_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> employeeSignup(EmployeeSignupModel model);
  Future<AuthResponseModel> employeeLogin(EmployeeLoginModel model);
  Future<AuthResponseModel> dashboardSignup(DashboardSignupModel model);
  Future<AuthResponseModel> dashboardLogin(DashboardLoginModel model);
  Future<AuthResponseModel> mobileSignup(MobileSignupModel model);
}

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl(this._dioClient);

  @override
  Future<AuthResponseModel> employeeSignup(EmployeeSignupModel model) =>
      _post(ApiEndpoints.signup, model.toJson());

  @override
  Future<AuthResponseModel> employeeLogin(EmployeeLoginModel model) =>
      _post(ApiEndpoints.login, model.toJson());

  @override
  Future<AuthResponseModel> dashboardSignup(DashboardSignupModel model) =>
      _post(ApiEndpoints.dashboardSignup, model.toJson());

  @override
  Future<AuthResponseModel> dashboardLogin(DashboardLoginModel model) =>
      _post(ApiEndpoints.dashboardLogin, model.toJson());

  @override
  Future<AuthResponseModel> mobileSignup(MobileSignupModel model) =>
      _post(ApiEndpoints.appSignup, model.toJson());

  Future<AuthResponseModel> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dioClient.post(path, data: body);
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _authError(e);
    }
  }

  AuthException _authError(DioException e) {
    final data = e.response?.data;
    final message = (data is Map && data['message'] is String)
        ? data['message'] as String
        : 'Could not reach the server. Please check your connection and try again.';
    return AuthException(
      message,
      isOffline: data is! Map || data['message'] is! String,
      statusCode: e.response?.statusCode,
    );
  }
}
