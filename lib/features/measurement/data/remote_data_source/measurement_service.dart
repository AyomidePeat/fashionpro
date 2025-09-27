import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fashionpro_app/features/measurement/data/model/measurement_model.dart';


class MeasurementService {
  final Dio dio;

  MeasurementService({required this.dio});

  Future<MeasurementResult> uploadImages({
    required File frontImage,
    required File sideImage,
    required num height,
  }) async {
    final formData = FormData.fromMap({
      "front": await MultipartFile.fromFile(frontImage.path),
      "side": await MultipartFile.fromFile(sideImage.path),
      "height_cm":height
    });

    final response = await dio.post("/measurements", data: formData);
    return MeasurementResult.fromJson(response.data["measurements"]);
  }
}
