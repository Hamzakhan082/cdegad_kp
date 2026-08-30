import 'dart:io';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/core/api/dashboard_api_adapter.dart';
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
      return DashboardApiAdapter.list(response.data)
          .map(
            (e) => AwarenessModel.fromJson(DashboardApiAdapter.awarenessRow(e)),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load awareness records: $e');
    }
  }

  @override
  Future<AwarenessModel> getById(String id) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.awarenessById(id));
      return AwarenessModel.fromJson(
        DashboardApiAdapter.awarenessRow(
          DashboardApiAdapter.record(response.data),
        ),
      );
    } catch (e) {
      throw Exception('Failed to load awareness record: $e');
    }
  }

  @override
  Future<AwarenessModel> create(AwarenessModel model) async {
    try {
      final fields = DashboardApiAdapter.awarenessRequest(model.toJson());
      final response = await _dioClient.post(
        ApiEndpoints.awareness,
        data: fields,
      );
      return AwarenessModel.fromJson(
        DashboardApiAdapter.awarenessRow(
          DashboardApiAdapter.record(response.data, fallback: fields),
        ),
      );
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
      final legacyFields = DashboardApiAdapter.awarenessRequest(fields);
      if (image != null) {
        legacyFields['upload_image'] =
            'data:image/jpeg;base64,${base64Encode(await File(image).readAsBytes())}';
      }
      if (document != null) {
        legacyFields['upload_documents'] =
            'data:application/octet-stream;base64,${base64Encode(await File(document).readAsBytes())}';
      }
      final response = await _dioClient.post(
        ApiEndpoints.awareness,
        data: legacyFields,
      );
      return AwarenessModel.fromJson(
        DashboardApiAdapter.awarenessRow(
          DashboardApiAdapter.record(response.data, fallback: legacyFields),
        ),
      );
    } catch (e) {
      throw Exception('Failed to create awareness record: $e');
    }
  }

  @override
  Future<AwarenessModel> update(String id, AwarenessModel model) async {
    try {
      final fields = DashboardApiAdapter.awarenessRequest(model.toJson());
      final response = await _dioClient.put(
        ApiEndpoints.awarenessById(id),
        data: fields,
      );
      return AwarenessModel.fromJson(
        DashboardApiAdapter.awarenessRow(
          DashboardApiAdapter.record(response.data, fallback: fields),
        ),
      );
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
