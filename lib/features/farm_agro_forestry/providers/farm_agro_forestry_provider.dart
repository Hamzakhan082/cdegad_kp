import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/farm_agro_forestry/models/farm_agro_forestry_model.dart';
import 'package:cdegad_kp/features/farm_agro_forestry/repositories/farm_agro_forestry_repository.dart';

final farmAgroForestryRepositoryProvider = Provider<FarmAgroForestryRepository>(
  (ref) {
    final dioClient = ref.read(dioClientProvider);
    return FarmAgroForestryRepositoryImpl(dioClient);
  },
);

class FarmAgroForestryNotifier
    extends StateNotifier<AsyncValue<List<FarmAgroForestryModel>>> {
  final FarmAgroForestryRepository _repository;

  FarmAgroForestryNotifier(this._repository)
    : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getAll();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => load();

  Future<FarmAgroForestryModel> create(FarmAgroForestryModel model) async {
    try {
      final created = await _repository.create(model);
      state = AsyncValue.data([created, ...state.value ?? []]);
      return created;
    } catch (e) {
      rethrow;
    }
  }

  Future<FarmAgroForestryModel> update(
    String id,
    FarmAgroForestryModel model,
  ) async {
    try {
      final updated = await _repository.update(id, model);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((e) => e.id == updated.id ? updated : e).toList(),
      );
      return updated;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((e) => e.id != id).toList());
    } catch (e) {
      rethrow;
    }
  }
}

final farmAgroForestryNotifierProvider =
    StateNotifierProvider<
      FarmAgroForestryNotifier,
      AsyncValue<List<FarmAgroForestryModel>>
    >((ref) {
      final repo = ref.read(farmAgroForestryRepositoryProvider);
      return FarmAgroForestryNotifier(repo);
    });
