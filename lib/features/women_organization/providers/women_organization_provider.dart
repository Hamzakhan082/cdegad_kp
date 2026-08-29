import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/features/women_organization/models/women_organization_model.dart';
import 'package:cdegad_kp/features/women_organization/repositories/women_organization_repository.dart';

final womenOrganizationListProvider =
    AsyncNotifierProvider<WomenOrganizationListNotifier, List<WomenOrganizationModel>>(
  WomenOrganizationListNotifier.new,
);

class WomenOrganizationListNotifier
    extends AsyncNotifier<List<WomenOrganizationModel>> {
  @override
  Future<List<WomenOrganizationModel>> build() async {
    return ref.read(womenOrganizationRepositoryProvider).getAll();
  }

  Future<WomenOrganizationModel> create(WomenOrganizationModel model) async {
    final repo = ref.read(womenOrganizationRepositoryProvider);
    final result = await repo.create(model);
    state = AsyncValue.data([result, ...state.value ?? []]);
    return result;
  }

  Future<WomenOrganizationModel> updateItem(
      String id, WomenOrganizationModel model) async {
    final repo = ref.read(womenOrganizationRepositoryProvider);
    final result = await repo.update(id, model);
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((e) => e.id == result.id ? result : e).toList(),
    );
    return result;
  }

  Future<void> remove(String id) async {
    final repo = ref.read(womenOrganizationRepositoryProvider);
    await repo.delete(id);
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((e) => e.id.toString() != id).toList());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(womenOrganizationRepositoryProvider).getAll());
  }
}

final womenOrganizationByIdProvider =
    FutureProvider.family<WomenOrganizationModel, String>((ref, id) async {
  return ref.read(womenOrganizationRepositoryProvider).getById(id);
});
