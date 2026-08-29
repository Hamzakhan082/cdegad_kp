import 'dart:io';

import 'package:dio/dio.dart';

import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';
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
  Future<YouthWomenNurseryModel> update(String id, YouthWomenNurseryModel model);
  Future<void> delete(String id);
}

class YouthWomenNurseryRepositoryImpl implements YouthWomenNurseryRepository {
  final DioClient _dioClient;

  YouthWomenNurseryRepositoryImpl(this._dioClient);

  @override
  Future<List<YouthWomenNurseryModel>> getAll() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.youthWomen);
      final data = response.data['data'] as List;
      return data.map((e) => YouthWomenNurseryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch nurseries: $e');
    }
  }

  @override
  Future<YouthWomenNurseryModel> getById(String id) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.youthWomenById(id));
      return YouthWomenNurseryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch nursery: $e');
    }
  }

  @override
  Future<YouthWomenNurseryModel> create(YouthWomenNurseryModel model) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.youthWomen,
        data: model.toJson(),
      );
      return YouthWomenNurseryModel.fromJson(response.data['data']);
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
        fileFields['upload_image'] = await MultipartFile.fromFile(image,
            filename: image.split(Platform.pathSeparator).last);
      }
      if (document != null) {
        fileFields['upload_file'] = await MultipartFile.fromFile(document,
            filename: document.split(Platform.pathSeparator).last);
      }
      final response = await _dioClient.postFormData(
        ApiEndpoints.youthWomen,
        fields: fields,
        fileFields: fileFields,
      );
      return YouthWomenNurseryModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create nursery: $e');
    }
  }

  @override
  Future<YouthWomenNurseryModel> update(String id, YouthWomenNurseryModel model) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.youthWomenById(id),
        data: model.toJson(),
      );
      return YouthWomenNurseryModel.fromJson(response.data['data']);
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
