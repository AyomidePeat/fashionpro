import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fashionpro_app/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MeasurementState {
  final bool isLoading;
  final Map<String, dynamic>? result;
  final String? error;

  const MeasurementState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  MeasurementState copyWith({
    bool? isLoading,
    Map<String, dynamic>? result,
    String? error,
  }) {
    return MeasurementState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class MeasurementNotifier extends StateNotifier<MeasurementState> {
  MeasurementNotifier(this._dio) : super(const MeasurementState());

  final Dio _dio;

  Future<void> uploadMeasurement(
    File front,
    File side,
    double heightCm,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null, result: null);

      final formData = FormData.fromMap({
        "front_photo": await MultipartFile.fromFile(front.path),
        "side_photo": await MultipartFile.fromFile(side.path),
        "height_cm": heightCm,
      });

      final response = await _dio.post("/measurements", data: formData);

      state = state.copyWith(isLoading: false, result: response.data);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:"Upload failed: ${e.toString()}",
      );
    }
  }
}

final measurementProvider =
    StateNotifierProvider<MeasurementNotifier, MeasurementState>((ref) {
  final dio = ref.read(dioProvider);
  return MeasurementNotifier(dio);
});
final dioProvider = Provider((ref) => DioClient().dio);
