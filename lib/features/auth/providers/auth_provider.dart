import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/auth/models/auth_response_model.dart';
import 'package:cdegad_kp/features/auth/models/dashboard_login_model.dart';
import 'package:cdegad_kp/features/auth/models/dashboard_signup_model.dart';
import 'package:cdegad_kp/features/auth/models/employee_login_model.dart';
import 'package:cdegad_kp/features/auth/models/employee_signup_model.dart';
import 'package:cdegad_kp/features/auth/models/mobile_signup_model.dart';
import 'package:cdegad_kp/features/auth/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(dioClientProvider));
});

enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthResponseModel? response;
  final String? errorMessage;
  final bool rememberMe;

  const AuthState({
    this.status = AuthStatus.initial,
    this.response,
    this.errorMessage,
    this.rememberMe = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthResponseModel? response,
    String? errorMessage,
    bool? rememberMe,
  }) {
    return AuthState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  Future<void> employeeLogin({
    required String emailAddress,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authRepository.employeeLogin(
        EmployeeLoginModel(
          emailAddress: emailAddress,
          password: password,
        ),
      );

      if (response.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.token!);
        if (response.user != null) {
          await prefs.setString('user_data', jsonEncode(response.user));
        }
        if (rememberMe) {
          await prefs.setString('saved_email', emailAddress);
          await prefs.setBool('remember_me', true);
        } else {
          await prefs.remove('saved_email');
          await prefs.setBool('remember_me', false);
        }
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        response: response,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> employeeSignup({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
    required String cnic,
    required String division,
    required String employeeNo,
    required String mobile,
    required String gender,
    String? photoPath,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final photo = photoPath != null ? File(photoPath) : null;
      final response = await _authRepository.employeeSignup(
        EmployeeSignupModel(
          fullName: fullName,
          emailAddress: emailAddress,
          password: password,
          confirmPassword: confirmPassword,
          cnic: cnic,
          division: division,
          employeeNo: employeeNo,
          mobile: mobile,
          gender: gender,
          photo: photo,
        ),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        response: response,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> dashboardSignup({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authRepository.dashboardSignup(
        DashboardSignupModel(
          fullName: fullName,
          emailAddress: emailAddress,
          password: password,
          confirmPassword: confirmPassword,
        ),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        response: response,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> dashboardLogin({
    required String emailAddress,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authRepository.dashboardLogin(
        DashboardLoginModel(
          emailAddress: emailAddress,
          password: password,
        ),
      );

      if (response.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.token!);
        if (response.user != null) {
          await prefs.setString('user_data', jsonEncode(response.user));
        }
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        response: response,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> mobileSignup({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
    required String mobile,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authRepository.mobileSignup(
        MobileSignupModel(
          fullName: fullName,
          emailAddress: emailAddress,
          password: password,
          confirmPassword: confirmPassword,
          mobile: mobile,
        ),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        response: response,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const AuthState();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.select((s) => s.status == AuthStatus.authenticated));
});
