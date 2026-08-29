import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/vdc/models/vdc_model.dart';
import 'package:cdegad_kp/features/vdc/repositories/vdc_repository.dart';

final vdcRepositoryProvider = Provider<VdcRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return VdcRepositoryImpl(dioClient);
});

final vdcListProvider =
    StateNotifierProvider<VdcListNotifier, AsyncValue<List<VdcModel>>>((ref) {
  return VdcListNotifier(ref.read(vdcRepositoryProvider));
});

class VdcListNotifier extends StateNotifier<AsyncValue<List<VdcModel>>> {
  final VdcRepository _repository;

  VdcListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getAllVdc();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => loadAll();

  Future<VdcModel?> create(VdcModel vdc) async {
    try {
      final created = await _repository.createVdc(vdc);
      state = AsyncValue.data([created, ...state.value ?? []]);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<VdcModel?> createMultipart(Map<String, dynamic> fields,
      {String? image, String? document}) async {
    try {
      final created = await _repository.createVdcMultipart(fields,
          image: image, document: document);
      state = AsyncValue.data([created, ...state.value ?? []]);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<VdcModel?> update(String id, VdcModel vdc) async {
    try {
      final updated = await _repository.updateVdc(id, vdc);
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
      await _repository.deleteVdc(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((e) => e.id.toString() != id).toList());
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final vdcCrudProvider = Provider<VdcCrud>((ref) {
  return VdcCrud(ref.read(vdcRepositoryProvider));
});

class VdcCrud {
  final VdcRepository _repository;

  VdcCrud(this._repository);

  Future<VdcModel> getById(String id) => _repository.getVdcById(id);
  Future<VdcModel> create(VdcModel vdc) => _repository.createVdc(vdc);
  Future<VdcModel> createMultipart(Map<String, dynamic> fields,
          {String? image, String? document}) =>
      _repository.createVdcMultipart(fields, image: image, document: document);
  Future<VdcModel> update(String id, VdcModel vdc) =>
      _repository.updateVdc(id, vdc);
  Future<void> delete(String id) => _repository.deleteVdc(id);
}
