import 'dart:io';
import 'dart:convert';

import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dashboard_api_adapter.dart';
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
      return DashboardApiAdapter.list(response.data)
          .map(
            (e) =>
                FarmAgroForestryModel.fromJson(DashboardApiAdapter.farmRow(e)),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch farm data');
    }
  }

  @override
  Future<FarmAgroForestryModel> getById(String id) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.farmAgroForestryById(id),
      );
      return FarmAgroForestryModel.fromJson(
        DashboardApiAdapter.farmRow(DashboardApiAdapter.record(response.data)),
      );
    } catch (e) {
      throw Exception('Failed to fetch farm');
    }
  }

  @override
  Future<FarmAgroForestryModel> create(FarmAgroForestryModel model) async {
    try {
      final fields = DashboardApiAdapter.farmRequest(model.toJson());
      final response = await _dioClient.post(
        ApiEndpoints.farmAgroForestry,
        data: fields,
      );
      return FarmAgroForestryModel.fromJson(
        DashboardApiAdapter.farmRow(
          DashboardApiAdapter.record(response.data, fallback: fields),
        ),
      );
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
      final legacyFields = DashboardApiAdapter.farmRequest(fields);
      if (image != null) {
        legacyFields['upload_image'] =
            'data:image/jpeg;base64,${base64Encode(await File(image).readAsBytes())}';
      }
      if (document != null) {
        legacyFields['upload_file'] =
            'data:application/octet-stream;base64,${base64Encode(await File(document).readAsBytes())}';
      }
      final response = await _dioClient.post(
        ApiEndpoints.farmAgroForestry,
        data: legacyFields,
      );
      return FarmAgroForestryModel.fromJson(
        DashboardApiAdapter.farmRow(
          DashboardApiAdapter.record(response.data, fallback: legacyFields),
        ),
      );
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
      final fields = DashboardApiAdapter.farmRequest(model.toJson());
      final response = await _dioClient.put(
        ApiEndpoints.farmAgroForestryById(id),
        data: fields,
      );
      return FarmAgroForestryModel.fromJson(
        DashboardApiAdapter.farmRow(
          DashboardApiAdapter.record(response.data, fallback: fields),
        ),
      );
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
