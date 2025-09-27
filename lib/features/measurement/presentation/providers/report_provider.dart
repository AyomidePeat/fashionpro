import 'dart:io';
import 'package:fashionpro_app/features/measurement/data/local_data_source/measurement_repo.dart';
import 'package:fashionpro_app/features/measurement/data/model/measurement_model.dart';
import 'package:fashionpro_app/features/measurement/data/remote_data_source/measurement_service.dart';
import 'package:fashionpro_app/features/measurement/presentation/providers/measurement_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final serviceProvider = Provider((ref) => MeasurementService(dio: ref.read(dioProvider)));
final repoProvider = Provider((ref) {
  final box = Hive.box<MeasurementResult>("measurements");
  return MeasurementRepository(box);
});

final resultProvider =
    StateNotifierProvider<ResultNotifier, AsyncValue<MeasurementResult?>>(
        (ref) {
  final service = ref.read(serviceProvider);
  final repo = ref.read(repoProvider);
  return ResultNotifier(service, repo);
});

class ResultNotifier extends StateNotifier<AsyncValue<MeasurementResult?>> {
  final MeasurementService service;
  final MeasurementRepository repo;

  ResultNotifier(this.service, this.repo)
      : super(const AsyncValue.data(null));

  Future<void> capture(File front, File side, num height) async {
    state = const AsyncValue.loading();
    try {
      final result = await service.uploadImages(frontImage: front, sideImage: side,height: height);
      await repo.save(result);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
