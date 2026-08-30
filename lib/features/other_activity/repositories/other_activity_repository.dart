import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dashboard_api_adapter.dart';
import 'package:cdegad_kp/features/other_activity/models/other_activity_model.dart';

abstract class OtherActivityRepository {
  Future<List<OtherActivityModel>> getAll();
  Future<OtherActivityModel> create(OtherActivityModel model);
  Future<OtherActivityModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  });
  Future<void> delete(String id);
}

class OtherActivityRepositoryImpl implements OtherActivityRepository {
  final DioClient _dioClient;

  OtherActivityRepositoryImpl(this._dioClient);

  @override
  Future<List<OtherActivityModel>> getAll() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.otherActivity);
      return DashboardApiAdapter.list(response.data)
          .map(
            (e) => OtherActivityModel.fromJson(DashboardApiAdapter.otherRow(e)),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch activities');
    }
  }

  @override
  Future<OtherActivityModel> create(OtherActivityModel model) async {
    try {
      final fields = DashboardApiAdapter.otherRequest(model.toJson());
      final response = await _dioClient.postFormData(
        ApiEndpoints.otherActivity,
        fields: fields,
      );
      return OtherActivityModel.fromJson(
        DashboardApiAdapter.otherRow(
          DashboardApiAdapter.record(response.data, fallback: fields),
        ),
      );
    } catch (e) {
      throw Exception('Failed to create activity');
    }
  }

  @override
  Future<OtherActivityModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  }) async {
    try {
      final fileFields = <String, MultipartFile>{};
      if (image != null) {
        fileFields['upload_image'] = await MultipartFile.fromFile(
          image,
          filename: image.split(Platform.pathSeparator).last,
        );
      }
      if (document != null) {
        fileFields['upload_file'] = await MultipartFile.fromFile(
          document,
          filename: document.split(Platform.pathSeparator).last,
        );
      }
      final legacyFields = DashboardApiAdapter.otherRequest(fields);
      final response = await _dioClient.postFormData(
        ApiEndpoints.otherActivity,
        fields: legacyFields,
        fileFields: fileFields,
      );
      return OtherActivityModel.fromJson(
        DashboardApiAdapter.otherRow(
          DashboardApiAdapter.record(response.data, fallback: legacyFields),
        ),
      );
    } catch (e) {
      throw Exception('Failed to create activity: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dioClient.delete(ApiEndpoints.otherActivityById(id));
    } catch (e) {
      throw Exception('Failed to delete activity');
    }
  }
}

final otherActivityRepositoryProvider = Provider<OtherActivityRepository>((
  ref,
) {
  final dioClient = ref.read(dioClientProvider);
  return OtherActivityRepositoryImpl(dioClient);
});
