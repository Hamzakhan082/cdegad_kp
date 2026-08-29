import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/jfmc/models/jfmc_model.dart';
import 'package:dio/dio.dart';

abstract class JfmcRepository {
  Future<List<JfmcModel>> getAllJfmc();
  Future<JfmcModel> getJfmcById(String id);
  Future<JfmcModel> createJfmc(JfmcModel jfmc);
  Future<JfmcModel> createJfmcMultipart(Map<String, dynamic> fields,
      {String? image, String? document});
  Future<JfmcModel> updateJfmc(String id, JfmcModel jfmc);
  Future<void> deleteJfmc(String id);
}

class JfmcRepositoryImpl implements JfmcRepository {
  final DioClient _dioClient;

  JfmcRepositoryImpl(this._dioClient);

  @override
  Future<List<JfmcModel>> getAllJfmc() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.jfmc);
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => JfmcModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch JFMC records: $e');
    }
  }

  @override
  Future<JfmcModel> getJfmcById(String id) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.jfmcById(id));
      return JfmcModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch JFMC record: $e');
    }
  }

  @override
  Future<JfmcModel> createJfmc(JfmcModel jfmc) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.jfmc,
        data: jfmc.toJson(),
      );
      return JfmcModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create JFMC record: $e');
    }
  }

  @override
  Future<JfmcModel> createJfmcMultipart(Map<String, dynamic> fields,
      {String? image, String? document}) async {
    try {
      final fileFields = <String, MultipartFile>{};
      if (image != null && image.isNotEmpty) {
        fileFields['upload_image'] =
            await MultipartFile.fromFile(image, filename: 'image');
      }
      if (document != null && document.isNotEmpty) {
        fileFields['upload_file'] =
            await MultipartFile.fromFile(document, filename: 'document');
      }
      final response = await _dioClient.postFormData(
        ApiEndpoints.jfmc,
        fields: fields,
        fileFields: fileFields,
      );
      return JfmcModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create JFMC record: $e');
    }
  }

  @override
  Future<JfmcModel> updateJfmc(String id, JfmcModel jfmc) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.jfmcById(id),
        data: jfmc.toJson(),
      );
      return JfmcModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update JFMC record: $e');
    }
  }

  @override
  Future<void> deleteJfmc(String id) async {
    try {
      await _dioClient.delete(ApiEndpoints.jfmcById(id));
    } catch (e) {
      throw Exception('Failed to delete JFMC record: $e');
    }
  }
}
