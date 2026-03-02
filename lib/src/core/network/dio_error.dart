import 'package:dio/dio.dart';

extension DioX on DioException {
  String get messageToUser {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data["message"]?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg;
    }

    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Internet sekin. Qayta urinib ko‘ring";
      case DioExceptionType.connectionError:
        return "Internet bilan muammo. Tarmoqni tekshiring";
      case DioExceptionType.badResponse:
        return "Server xatoligi";
      case DioExceptionType.cancel:
        return "So‘rov bekor qilindi";
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return "Kutilmagan xatolik";
    }
  }
}
