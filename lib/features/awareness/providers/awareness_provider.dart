import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/features/awareness/models/awareness_model.dart';
import 'package:cdegad_kp/features/awareness/repositories/awareness_repository.dart';

final awarenessListProvider =
    StateNotifierProvider<AwarenessListNotifier, AsyncValue<List<AwarenessModel>>>(
  (ref) => AwarenessListNotifier(ref),
);

class AwarenessListNotifier extends StateNotifier<AsyncValue<List<AwarenessModel>>> {
  final Ref _ref;

  AwarenessListNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  AwarenessRepository get _repo => _ref.read(awarenessRepositoryProvider);

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.getAll();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => load();

  Future<AwarenessModel> create(AwarenessModel model) async {
    try {
      final created = await _repo.create(model);
      state = AsyncValue.data([created, ...state.value ?? []]);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<AwarenessModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  }) async {
    try {
      final created = await _repo.createMultipart(fields, image: image, document: document);
      state = AsyncValue.data([created, ...state.value ?? []]);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<AwarenessModel> update(String id, AwarenessModel model) async {
    try {
      final updated = await _repo.update(id, model);
      final current = state.value ?? [];
      state = AsyncValue.data([
        for (final item in current) item.id == updated.id ? updated : item,
      ]);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.delete(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((item) => item.id.toString() != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
