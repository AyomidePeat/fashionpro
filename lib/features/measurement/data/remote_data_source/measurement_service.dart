 import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fashionpro_app/core/network/dio_client.dart';
import 'package:fashionpro_app/features/measurement/data/model/measurement_model.dart';


class MeasurementService {
  final Dio _dio = DioClient.create();

  Future<MeasurementResult> uploadImages({
    required File frontImage,
    required File sideImage,
  }) async {
    final formData = FormData.fromMap({
      "front": await MultipartFile.fromFile(frontImage.path),
      "side": await MultipartFile.fromFile(sideImage.path),
    });

    final response = await _dio.post("/measurements", data: formData);
    return MeasurementResult.fromJson(response.data);
  }
}
