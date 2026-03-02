import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/storage/shared_storage.dart';
import '../models/response/booking_model.dart';
import 'in_progress_data_source.dart';

class InProgressDataSourceImp implements BookingRemoteDataSource {
  final Dio dio;

  InProgressDataSourceImp(this.dio);

  @override
  Future<List<BookingModel>> getMyInProgressBookings() async {
    final token = Prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Access token not found");
    }

    try {
      final res = await dio.get(
        '/api/bookings/my/for/passenger/in-progress',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint("Bookings response data: ${res.data}");
      debugPrint("Bookings response type: ${res.data.runtimeType}");

      if (res.data is! List) {
        throw const FormatException("Invalid bookings response format");
      }

      final list = (res.data as List)
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // ✅ DEBUG: API dan kelayotgan status qiymatlarini ko'rish
      for (final b in list) {
        debugPrint("BOOKING id=${b.id} status='${b.status}' offeredPrice=${b.offeredPrice}");
      }

      return list;
    }
    on DioException catch (e) {
      throw _mapDioError(e);
    }
    on FormatException catch (e) {
      throw Exception(e.message);
    }
    catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Exception _mapDioError(DioException e) {
    // Timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception("Serverga ulanish vaqti tugadi");
    }

    // No internet
    if (e.type == DioExceptionType.connectionError) {
      return Exception("Internet aloqasi yo‘q");
    }

    // Backend response
    if (e.response != null) {
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return Exception(message);
        }
      }

      return Exception(
        "Server error (${e.response!.statusCode})",
      );
    }

    return Exception("Noma’lum tarmoq xatosi");
  }
}