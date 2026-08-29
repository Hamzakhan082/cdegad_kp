import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/features/women_organization/models/women_organization_model.dart';

abstract class WomenOrganizationRepository {
  Future<List<WomenOrganizationModel>> getAll();
  Future<WomenOrganizationModel> getById(String id);
  Future<WomenOrganizationModel> create(WomenOrganizationModel model);
  Future<WomenOrganizationModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  });
  Future<WomenOrganizationModel> update(String id, WomenOrganizationModel model);
  Future<void> delete(String id);
}

class WomenOrganizationRepositoryImpl implements WomenOrganizationRepository {
  final DioClient _dioClient;

  WomenOrganizationRepositoryImpl(this._dioClient);

  @override
  Future<List<WomenOrganizationModel>> getAll() async {
    try {
      final response =
          await _dioClient.get(ApiEndpoints.womenOrganization);
      final data = response.data['data'] as List;
      return data.map((e) => WomenOrganizationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch organizations');
    }
  }

  @override
  Future<WomenOrganizationModel> getById(String id) async {
    try {
      final response =
          await _dioClient.get(ApiEndpoints.womenOrganizationById(id));
      return WomenOrganizationModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch organization');
    }
  }

  @override
  Future<WomenOrganizationModel> create(WomenOrganizationModel model) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.womenOrganization,
        data: model.toJson(),
      );
      return WomenOrganizationModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create organization');
    }
  }

  @override
  Future<WomenOrganizationModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  }) async {
    try {
      final fileFields = <String, MultipartFile>{};
      if (image != null) {
        fileFields['upload_image'] = await MultipartFile.fromFile(image,
            filename: image.split(Platform.pathSeparator).last);
      }
      if (document != null) {
        fileFields['upload_file'] = await MultipartFile.fromFile(document,
            filename: document.split(Platform.pathSeparator).last);
      }
      final response = await _dioClient.postFormData(
        ApiEndpoints.womenOrganization,
        fields: fields,
        fileFields: fileFields,
      );
      return WomenOrganizationModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create organization: $e');
    }
  }

  @override
  Future<WomenOrganizationModel> update(
    String id,
    WomenOrganizationModel model,
  ) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.womenOrganizationById(id),
        data: model.toJson(),
      );
      return WomenOrganizationModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update organization');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dioClient.delete(ApiEndpoints.womenOrganizationById(id));
    } catch (e) {
      throw Exception('Failed to delete organization');
    }
  }
}

final womenOrganizationRepositoryProvider =
    Provider<WomenOrganizationRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return WomenOrganizationRepositoryImpl(dioClient);
});
