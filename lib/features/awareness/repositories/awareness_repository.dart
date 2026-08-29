import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/awareness/models/awareness_model.dart';

abstract class AwarenessRepository {
  Future<List<AwarenessModel>> getAll();
  Future<AwarenessModel> getById(String id);
  Future<AwarenessModel> create(AwarenessModel model);
  Future<AwarenessModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  });
  Future<AwarenessModel> update(String id, AwarenessModel model);
  Future<void> delete(String id);
}

class AwarenessRepositoryImpl implements AwarenessRepository {
  final DioClient _dioClient;

  AwarenessRepositoryImpl(this._dioClient);

  @override
  Future<List<AwarenessModel>> getAll() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.awareness);
      final data = response.data['data'] as List;
      return data.map((e) => AwarenessModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load awareness records: $e');
    }
  }

  @override
  Future<AwarenessModel> getById(String id) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.awarenessById(id));
      return AwarenessModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load awareness record: $e');
    }
  }

  @override
  Future<AwarenessModel> create(AwarenessModel model) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.awareness,
        data: model.toJson(),
      );
      return AwarenessModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create awareness record: $e');
    }
  }

  @override
  Future<AwarenessModel> createMultipart(
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
        ApiEndpoints.awareness,
        fields: fields,
        fileFields: fileFields,
      );
      return AwarenessModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create awareness record: $e');
    }
  }

  @override
  Future<AwarenessModel> update(String id, AwarenessModel model) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.awarenessById(id),
        data: model.toJson(),
      );
      return AwarenessModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update awareness record: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dioClient.delete(ApiEndpoints.awarenessById(id));
    } catch (e) {
      throw Exception('Failed to delete awareness record: $e');
    }
  }
}

final awarenessRepositoryProvider = Provider<AwarenessRepository>(
  (ref) => AwarenessRepositoryImpl(ref.read(dioClientProvider)),
);
