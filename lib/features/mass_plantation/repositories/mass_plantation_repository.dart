import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/mass_plantation/models/mass_plantation_model.dart';

abstract class MassPlantationRepository {
  Future<List<MassPlantationModel>> getAll();
  Future<MassPlantationModel> getById(String id);
  Future<MassPlantationModel> create(MassPlantationModel model);
  Future<MassPlantationModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  });
  Future<MassPlantationModel> update(String id, MassPlantationModel model);
  Future<void> delete(String id);
}

class MassPlantationRepositoryImpl implements MassPlantationRepository {
  final DioClient _dioClient;

  MassPlantationRepositoryImpl(this._dioClient);

  @override
  Future<List<MassPlantationModel>> getAll() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.massPlantation);
      final data = response.data['data'] as List;
      return data.map((e) => MassPlantationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load mass plantations: $e');
    }
  }

  @override
  Future<MassPlantationModel> getById(String id) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.massPlantationById(id));
      return MassPlantationModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load mass plantation: $e');
    }
  }

  @override
  Future<MassPlantationModel> create(MassPlantationModel model) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.massPlantation,
        data: model.toJson(),
      );
      return MassPlantationModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create mass plantation: $e');
    }
  }

  @override
  Future<MassPlantationModel> createMultipart(
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
        ApiEndpoints.massPlantation,
        fields: fields,
        fileFields: fileFields,
      );
      return MassPlantationModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create mass plantation: $e');
    }
  }

  @override
  Future<MassPlantationModel> update(String id, MassPlantationModel model) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.massPlantationById(id),
        data: model.toJson(),
      );
      return MassPlantationModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update mass plantation: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dioClient.delete(ApiEndpoints.massPlantationById(id));
    } catch (e) {
      throw Exception('Failed to delete mass plantation: $e');
    }
  }
}

final massPlantationRepositoryProvider = Provider<MassPlantationRepository>(
  (ref) => MassPlantationRepositoryImpl(ref.read(dioClientProvider)),
);
