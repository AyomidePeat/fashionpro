import 'package:dio/dio.dart';

class ErrorHandler {
  static String getMessage(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout) {
        return "Connection timeout. Please try again.";
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return "Server took too long to respond.";
      } else if (error.response != null) {
        return error.response?.data["message"] ?? "Unexpected server error.";
      } else {
        return "Network error. Please check your connection.";
      }
    }
    return "Something went wrong.";
  }
}
