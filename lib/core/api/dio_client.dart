import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cdegad_kp/core/config/app_config.dart';
import 'package:cdegad_kp/core/api/app_interceptor.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final client = DioClient();
  client._initInterceptors();
  return client;
});

class DioClient {
  late final Dio _dio;
  bool _interceptorsInitialized = false;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<void> _initInterceptors() async {
    if (_interceptorsInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    _dio.interceptors.clear();
    _dio.interceptors.add(AppInterceptor(prefs: prefs, onUnauthorized: () {}));
    _interceptorsInitialized = true;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _initInterceptors();
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _initInterceptors();
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _initInterceptors();
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _initInterceptors();
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> postMultipart(
    String path, {
    required Map<String, dynamic> fields,
    required List<MultipartFile> files,
    String fileFieldName = 'files',
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    await _initInterceptors();
    final formData = FormData.fromMap({
      ...fields,
      fileFieldName: files.length == 1 ? files.first : files,
    });

    return _dio.post(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options?.copyWith(contentType: 'multipart/form-data'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// Posts a multipart form where each file is sent under an explicit field
  /// name (e.g. `upload_image`, `upload_file`) so the backend can store them.
  Future<Response> postFormData(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, MultipartFile>? fileFields,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    await _initInterceptors();
    final formData = FormData.fromMap({...fields, ...?fileFields});

    return _dio.post(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options?.copyWith(contentType: 'multipart/form-data'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// Downloads a file as raw bytes (e.g. from the `/uploads` static route).
  Future<Response<List<int>>> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _initInterceptors();
    return _dio.get<List<int>>(
      path,
      queryParameters: queryParameters,
      options: options?.copyWith(responseType: ResponseType.bytes),
      cancelToken: cancelToken,
    );
  }
}
