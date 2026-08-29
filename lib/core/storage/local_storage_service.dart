import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class LocalStorageService {
  Directory? _dir;
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  final Map<String, Completer<void>?> _locks = {};

  Future<Directory> _getDir() async {
    if (_dir != null) return _dir!;
    _dir = await getApplicationDocumentsDirectory();
    return _dir!;
  }

  Future<void> _acquireLock(String collection) async {
    while (_locks[collection] != null) {
      await _locks[collection]!.future;
    }
    _locks[collection] = Completer<void>();
  }

  void _releaseLock(String collection) {
    final completer = _locks[collection];
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _locks[collection] = null;
  }

  Future<File> _file(String collection) async {
    final dir = await _getDir();
    final path = '${dir.path}/$collection.json';
    final file = File(path);
    if (!await file.exists()) {
      await file.writeAsString('[]');
    }
    return file;
  }

  Future<List<Map<String, dynamic>>> getAll(String collection) async {
    if (_cache.containsKey(collection)) {
      return List.from(_cache[collection]!);
    }
    try {
      final file = await _file(collection);
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is List) {
        final items = decoded.cast<Map<String, dynamic>>();
        _cache[collection] = items;
        return List.from(items);
      }
      _cache[collection] = [];
      return [];
    } catch (_) {
      _cache[collection] = [];
      return [];
    }
  }

  Future<Map<String, dynamic>?> getById(String collection, String id) async {
    final items = await getAll(collection);
    for (final item in items) {
      if (item['id'].toString() == id) return item;
    }
    return null;
  }

  Future<Map<String, dynamic>> create(
      String collection, Map<String, dynamic> data) async {
    await _acquireLock(collection);
    try {
      final items = await getAll(collection);
      final id = data['id'] ?? _generateId(items);
      final record = {
        ...data,
        'id': id,
        'created_at': DateTime.now().toIso8601String()
      };
      items.insert(0, record);
      _cache[collection] = items;
      await _save(collection, items);
      return record;
    } finally {
      _releaseLock(collection);
    }
  }

  Future<Map<String, dynamic>> update(
      String collection, String id, Map<String, dynamic> data) async {
    await _acquireLock(collection);
    try {
      final items = await getAll(collection);
      final index = items.indexWhere((e) => e['id'].toString() == id);
      if (index == -1) throw Exception('Record not found');
      final updated = {
        ...items[index],
        ...data,
        'id': items[index]['id'],
        'updated_at': DateTime.now().toIso8601String()
      };
      items[index] = updated;
      _cache[collection] = items;
      await _save(collection, items);
      return updated;
    } finally {
      _releaseLock(collection);
    }
  }

  Future<void> delete(String collection, String id) async {
    await _acquireLock(collection);
    try {
      final items = await getAll(collection);
      items.removeWhere((e) => e['id'].toString() == id);
      _cache[collection] = items;
      await _save(collection, items);
    } finally {
      _releaseLock(collection);
    }
  }

  void invalidate(String collection) {
    _cache.remove(collection);
  }

  void invalidateAll() {
    _cache.clear();
  }

  Future<void> _save(
      String collection, List<Map<String, dynamic>> items) async {
    final file = await _file(collection);
    await file.writeAsString(jsonEncode(items));
  }

  int _generateId(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return 1;
    int maxId = 0;
    for (final item in items) {
      final id = item['id'];
      if (id is int && id > maxId) maxId = id;
    }
    return maxId + 1;
  }
}
