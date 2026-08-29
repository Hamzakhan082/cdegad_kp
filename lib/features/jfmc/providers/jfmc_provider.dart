import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/jfmc/models/jfmc_model.dart';
import 'package:cdegad_kp/features/jfmc/repositories/jfmc_repository.dart';

final jfmcRepositoryProvider = Provider<JfmcRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return JfmcRepositoryImpl(dioClient);
});

final jfmcListProvider = StateNotifierProvider<JfmcListNotifier,
    AsyncValue<List<JfmcModel>>>((ref) {
  return JfmcListNotifier(ref.read(jfmcRepositoryProvider));
});

class JfmcListNotifier extends StateNotifier<AsyncValue<List<JfmcModel>>> {
  final JfmcRepository _repository;

  JfmcListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getAllJfmc();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => loadAll();

  Future<JfmcModel?> create(JfmcModel jfmc) async {
    try {
      final created = await _repository.createJfmc(jfmc);
      state = AsyncValue.data([created, ...state.value ?? []]);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<JfmcModel?> createMultipart(Map<String, dynamic> fields,
      {String? image, String? document}) async {
    try {
      final created = await _repository.createJfmcMultipart(fields,
          image: image, document: document);
      state = AsyncValue.data([created, ...state.value ?? []]);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<JfmcModel?> update(String id, JfmcModel jfmc) async {
    try {
      final updated = await _repository.updateJfmc(id, jfmc);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((e) => e.id == updated.id ? updated : e).toList(),
      );
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repository.deleteJfmc(id);
      final current = state.value ?? [];
      state =
          AsyncValue.data(current.where((e) => e.id.toString() != id).toList());
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final jfmcCrudProvider = Provider<JfmcCrud>((ref) {
  return JfmcCrud(ref.read(jfmcRepositoryProvider));
});

class JfmcCrud {
  final JfmcRepository _repository;

  JfmcCrud(this._repository);

  Future<JfmcModel> getById(String id) => _repository.getJfmcById(id);
  Future<JfmcModel> create(JfmcModel jfmc) => _repository.createJfmc(jfmc);
  Future<JfmcModel> createMultipart(Map<String, dynamic> fields,
          {String? image, String? document}) =>
      _repository.createJfmcMultipart(fields, image: image, document: document);
  Future<JfmcModel> update(String id, JfmcModel jfmc) =>
      _repository.updateJfmc(id, jfmc);
  Future<void> delete(String id) => _repository.deleteJfmc(id);
}
