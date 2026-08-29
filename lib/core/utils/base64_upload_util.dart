import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class Base64UploadUtil {
  Base64UploadUtil._();

  static String fileToBase64(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    return base64Encode(bytes);
  }

  static String fileToBase64WithMime(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    final base64Data = base64Encode(bytes);
    final mime = _mimeType(filePath);
    return 'data:$mime;base64,$base64Data';
  }

  static Map<String, String> createBase64Payload(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    final base64Data = base64Encode(bytes);
    final fileName = p.basename(filePath);
    final mime = _mimeType(filePath);
    return {
      'fileName': fileName,
      'fileBase64': base64Data,
      'contentType': mime,
    };
  }

  static List<Map<String, String>> createMultipleBase64Payloads(
    List<String> filePaths,
  ) {
    return filePaths.map(createBase64Payload).toList();
  }

  static String _mimeType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    return switch (ext) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.gif' => 'image/gif',
      '.webp' => 'image/webp',
      '.pdf' => 'application/pdf',
      '.doc' => 'application/msword',
      '.docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      '.xls' => 'application/vnd.ms-excel',
      '.xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      '.txt' => 'text/plain',
      '.csv' => 'text/csv',
      _ => 'application/octet-stream',
    };
  }
}
