import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    String message = 'Serveur indisponible. Verifiez que le backend est lance.';
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    } else if (e.message != null) {
      message = e.message!;
    }
    return ApiException(message, statusCode: e.response?.statusCode);
  }

  @override
  String toString() => message;
}
