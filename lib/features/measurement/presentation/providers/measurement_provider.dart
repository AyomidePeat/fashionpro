import 'dart:io';
import 'package:fashionpro_app/features/measurement/data/model/measurement_model.dart';
import 'package:fashionpro_app/features/measurement/data/remote_data_source/measurement_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final measurementServiceProvider = Provider((ref) => MeasurementService());

final measurementResultProvider =
    StateNotifierProvider<MeasurementNotifier, AsyncValue<MeasurementResult?>>(
        (ref) {
  final service = ref.read(measurementServiceProvider);
  return MeasurementNotifier(service);
});

class MeasurementNotifier extends StateNotifier<AsyncValue<MeasurementResult?>> {
  final MeasurementService service;

  MeasurementNotifier(this.service) : super(const AsyncValue.data(null));

  Future<void> capture(File front, File side) async {
    state = const AsyncValue.loading();
    try {
      final result = await service.uploadImages(
        frontImage: front,
        sideImage: side,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
