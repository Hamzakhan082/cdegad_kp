import 'dart:io';

import 'package:dio/dio.dart';

import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/core/api/dashboard_api_adapter.dart';
import 'package:cdegad_kp/features/youth_women_nursery/models/youth_women_nursery_model.dart';

abstract class YouthWomenNurseryRepository {
  Future<List<YouthWomenNurseryModel>> getAll();
  Future<YouthWomenNurseryModel> getById(String id);
  Future<YouthWomenNurseryModel> create(YouthWomenNurseryModel model);
  Future<YouthWomenNurseryModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  });
  Future<YouthWomenNurseryModel> update(
    String id,
    YouthWomenNurseryModel model,
  );
  Future<void> delete(String id);
}

class YouthWomenNurseryRepositoryImpl implements YouthWomenNurseryRepository {
  final DioClient _dioClient;

  YouthWomenNurseryRepositoryImpl(this._dioClient);

  @override
  Future<List<YouthWomenNurseryModel>> getAll() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.youthWomen);
      return DashboardApiAdapter.list(response.data)
          .map(
            (e) => YouthWomenNurseryModel.fromJson(
              DashboardApiAdapter.youthRow(e),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch nurseries: $e');
    }
  }

  @override
  Future<YouthWomenNurseryModel> getById(String id) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.youthWomenById(id));
      return YouthWomenNurseryModel.fromJson(
        DashboardApiAdapter.youthRow(DashboardApiAdapter.record(response.data)),
      );
    } catch (e) {
      throw Exception('Failed to fetch nursery: $e');
    }
  }

  @override
  Future<YouthWomenNurseryModel> create(YouthWomenNurseryModel model) async {
    try {
      final fields = DashboardApiAdapter.youthRequest(model.toJson());
      final response = await _dioClient.postFormData(
        ApiEndpoints.youthWomen,
        fields: fields,
      );
      return YouthWomenNurseryModel.fromJson(
        DashboardApiAdapter.youthRow(
          DashboardApiAdapter.record(response.data, fallback: fields),
        ),
      );
    } catch (e) {
      throw Exception('Failed to create nursery: $e');
    }
  }

  @override
  Future<YouthWomenNurseryModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  }) async {
    try {
      final fileFields = <String, MultipartFile>{};
      if (image != null) {
        fileFields['Upload_Image'] = await MultipartFile.fromFile(
          image,
          filename: image.split(Platform.pathSeparator).last,
        );
      }
      if (document != null) {
        fileFields['Upload_File'] = await MultipartFile.fromFile(
          document,
          filename: document.split(Platform.pathSeparator).last,
        );
      }
      final legacyFields = DashboardApiAdapter.youthRequest(fields);
      final response = await _dioClient.postFormData(
        ApiEndpoints.youthWomen,
        fields: legacyFields,
        fileFields: fileFields,
      );
      return YouthWomenNurseryModel.fromJson(
        DashboardApiAdapter.youthRow(
          DashboardApiAdapter.record(response.data, fallback: legacyFields),
        ),
      );
    } catch (e) {
      throw Exception('Failed to create nursery: $e');
    }
  }

  @override
  Future<YouthWomenNurseryModel> update(
    String id,
    YouthWomenNurseryModel model,
  ) async {
    try {
      final fields = DashboardApiAdapter.youthRequest(model.toJson());
      final response = await _dioClient.put(
        ApiEndpoints.youthWomenById(id),
        data: fields,
      );
      return YouthWomenNurseryModel.fromJson(
        DashboardApiAdapter.youthRow(
          DashboardApiAdapter.record(response.data, fallback: fields),
        ),
      );
    } catch (e) {
      throw Exception('Failed to update nursery: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dioClient.delete(ApiEndpoints.youthWomenById(id));
    } catch (e) {
      throw Exception('Failed to delete nursery: $e');
    }
  }
}
