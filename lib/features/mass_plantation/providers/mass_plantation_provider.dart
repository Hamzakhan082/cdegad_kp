import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/features/mass_plantation/models/mass_plantation_model.dart';
import 'package:cdegad_kp/features/mass_plantation/repositories/mass_plantation_repository.dart';

final massPlantationListProvider =
    StateNotifierProvider<MassPlantationListNotifier, AsyncValue<List<MassPlantationModel>>>(
  (ref) => MassPlantationListNotifier(ref),
);

class MassPlantationListNotifier extends StateNotifier<AsyncValue<List<MassPlantationModel>>> {
  final Ref _ref;

  MassPlantationListNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  MassPlantationRepository get _repo => _ref.read(massPlantationRepositoryProvider);

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

  Future<MassPlantationModel> create(MassPlantationModel model) async {
    try {
      final created = await _repo.create(model);
      state = AsyncValue.data([created, ...state.value ?? []]);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<MassPlantationModel> createMultipart(
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

  Future<MassPlantationModel> update(String id, MassPlantationModel model) async {
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
