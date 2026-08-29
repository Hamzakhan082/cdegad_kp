import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class FileUploadUtil {
  FileUploadUtil._();

  static Future<File?> pickImage({bool fromCamera = false}) async {
    if (fromCamera) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked == null) return null;
      return File(picked.path);
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return File(result.files.first.path!);
  }

  static Future<List<File>> pickMultipleImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return [];
    return result.files.map((f) => File(f.path!)).toList();
  }

  static Future<File?> pickFile({List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return File(result.files.first.path!);
  }

  static Future<MultipartFile> createMultipartFile(
    String filePath, {
    String? fieldName,
  }) async {
    final file = File(filePath);
    final fileName = fieldName ?? p.basename(filePath);
    return MultipartFile.fromFile(filePath, filename: fileName);
  }

  static Future<List<MultipartFile>> createMultipleMultipartFiles(
    List<String> filePaths,
  ) async {
    final futures = filePaths.map((path) => createMultipartFile(path));
    return Future.wait(futures);
  }
}
