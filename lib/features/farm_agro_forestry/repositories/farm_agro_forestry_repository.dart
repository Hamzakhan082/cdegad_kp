import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/features/farm_agro_forestry/models/farm_agro_forestry_model.dart';

abstract class FarmAgroForestryRepository {
  Future<List<FarmAgroForestryModel>> getAll();
  Future<FarmAgroForestryModel> getById(String id);
  Future<FarmAgroForestryModel> create(FarmAgroForestryModel model);
  Future<FarmAgroForestryModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  });
  Future<FarmAgroForestryModel> update(String id, FarmAgroForestryModel model);
  Future<void> delete(String id);
}

class FarmAgroForestryRepositoryImpl implements FarmAgroForestryRepository {
  final DioClient _dioClient;

  FarmAgroForestryRepositoryImpl(this._dioClient);

  @override
  Future<List<FarmAgroForestryModel>> getAll() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.farmAgroForestry);
      final data = response.data['data'] as List;
      return data.map((e) => FarmAgroForestryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch farm data');
    }
  }

  @override
  Future<FarmAgroForestryModel> getById(String id) async {
    try {
      final response =
          await _dioClient.get(ApiEndpoints.farmAgroForestryById(id));
      return FarmAgroForestryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch farm');
    }
  }

  @override
  Future<FarmAgroForestryModel> create(FarmAgroForestryModel model) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.farmAgroForestry,
        data: model.toJson(),
      );
      return FarmAgroForestryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create farm');
    }
  }

  @override
  Future<FarmAgroForestryModel> createMultipart(
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
        ApiEndpoints.farmAgroForestry,
        fields: fields,
        fileFields: fileFields,
      );
      return FarmAgroForestryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create farm: $e');
    }
  }

  @override
  Future<FarmAgroForestryModel> update(
    String id,
    FarmAgroForestryModel model,
  ) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.farmAgroForestryById(id),
        data: model.toJson(),
      );
      return FarmAgroForestryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update farm');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dioClient.delete(ApiEndpoints.farmAgroForestryById(id));
    } catch (e) {
      throw Exception('Failed to delete farm');
    }
  }
}
