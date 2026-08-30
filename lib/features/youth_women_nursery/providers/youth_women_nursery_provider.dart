import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cdegad_kp/core/api/dio_client.dart';
import 'package:cdegad_kp/features/youth_women_nursery/models/youth_women_nursery_model.dart';
import 'package:cdegad_kp/features/youth_women_nursery/repositories/youth_women_nursery_repository.dart';

final youthWomenNurseryRepositoryProvider =
    Provider<YouthWomenNurseryRepository>((ref) {
      final dioClient = ref.read(dioClientProvider);
      return YouthWomenNurseryRepositoryImpl(dioClient);
    });

class YouthWomenNurseryNotifier
    extends StateNotifier<AsyncValue<List<YouthWomenNurseryModel>>> {
  final YouthWomenNurseryRepository _repository;

  YouthWomenNurseryNotifier(this._repository)
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

  Future<YouthWomenNurseryModel> create(YouthWomenNurseryModel model) async {
    final created = await _repository.create(model);
    state = AsyncValue.data([created, ...state.value ?? []]);
    return created;
  }

  Future<YouthWomenNurseryModel> createMultipart(
    Map<String, dynamic> fields, {
    String? image,
    String? document,
  }) async {
    final created = await _repository.createMultipart(
      fields,
      image: image,
      document: document,
    );
    state = AsyncValue.data([created, ...state.value ?? []]);
    return created;
  }

  Future<YouthWomenNurseryModel> update(
    String id,
    YouthWomenNurseryModel model,
  ) async {
    final updated = await _repository.update(id, model);
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((e) => e.id == updated.id ? updated : e).toList(),
    );
    return updated;
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    final current = state.value ?? [];
    state = AsyncValue.data(current.where((e) => e.id != id).toList());
  }
}

final youthWomenNurseryNotifierProvider =
    StateNotifierProvider<
      YouthWomenNurseryNotifier,
      AsyncValue<List<YouthWomenNurseryModel>>
    >((ref) {
      final repo = ref.read(youthWomenNurseryRepositoryProvider);
      return YouthWomenNurseryNotifier(repo);
    });
