import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/vdc/models/vdc_model.dart';
import 'package:dio/dio.dart';

abstract class VdcRepository {
  Future<List<VdcModel>> getAllVdc();
  Future<VdcModel> getVdcById(String id);
  Future<VdcModel> createVdc(VdcModel vdc);
  Future<VdcModel> createVdcMultipart(Map<String, dynamic> fields,
      {String? image, String? document});
  Future<VdcModel> updateVdc(String id, VdcModel vdc);
  Future<void> deleteVdc(String id);
}

class VdcRepositoryImpl implements VdcRepository {
  final DioClient _dioClient;

  VdcRepositoryImpl(this._dioClient);

  @override
  Future<List<VdcModel>> getAllVdc() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.vdc);
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => VdcModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch VDC records: $e');
    }
  }

  @override
  Future<VdcModel> getVdcById(String id) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.vdcById(id));
      return VdcModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch VDC record: $e');
    }
  }

  @override
  Future<VdcModel> createVdc(VdcModel vdc) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.vdc,
        data: vdc.toJson(),
      );
      return VdcModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create VDC record: $e');
    }
  }

  @override
  Future<VdcModel> createVdcMultipart(Map<String, dynamic> fields,
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
        ApiEndpoints.vdc,
        fields: fields,
        fileFields: fileFields,
      );
      return VdcModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create VDC record: $e');
    }
  }

  @override
  Future<VdcModel> updateVdc(String id, VdcModel vdc) async {
    try {
      final response = await _dioClient.put(
        ApiEndpoints.vdcById(id),
        data: vdc.toJson(),
      );
      return VdcModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update VDC record: $e');
    }
  }

  @override
  Future<void> deleteVdc(String id) async {
    try {
      await _dioClient.delete(ApiEndpoints.vdcById(id));
    } catch (e) {
      throw Exception('Failed to delete VDC record: $e');
    }
  }
}
