import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/features/other_activity/models/other_activity_model.dart';
import 'package:cdegad_kp/features/other_activity/repositories/other_activity_repository.dart';

final otherActivityListProvider =
    AsyncNotifierProvider<OtherActivityListNotifier, List<OtherActivityModel>>(
      OtherActivityListNotifier.new,
    );

class OtherActivityListNotifier
    extends AsyncNotifier<List<OtherActivityModel>> {
  @override
  Future<List<OtherActivityModel>> build() async {
    return ref.read(otherActivityRepositoryProvider).getAll();
  }

  Future<OtherActivityModel> create(OtherActivityModel model) async {
    final repo = ref.read(otherActivityRepositoryProvider);
    final result = await repo.create(model);
    state = AsyncValue.data([result, ...state.value ?? []]);
    return result;
  }

  Future<void> remove(String id) async {
    final repo = ref.read(otherActivityRepositoryProvider);
    await repo.delete(id);
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.where((e) => e.id.toString() != id).toList(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(otherActivityRepositoryProvider).getAll(),
    );
  }
}
