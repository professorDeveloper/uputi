import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../domain/ds/accept_booking_datasource.dart';

class AcceptDriverBookingDataSourceImpl
    implements AcceptDriverBookingDataSource {
  final Dio dio;

  AcceptDriverBookingDataSourceImpl(this.dio);

  @override
  Future<String> acceptBooking(int bookingId) async {
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.post(
        '/api/bookings/$bookingId/accept',
        data: {},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('Accept booking RESPONSE: ${res.data}');
      return res.data['message']?.toString() ?? 'Booking qabul qilindi';
    } on DioException catch (e) {
      debugPrint('Accept booking URL: ${e.requestOptions.uri}');
      debugPrint('Accept booking STATUS: ${e.response?.statusCode}');
      debugPrint('Accept booking BODY: ${e.response?.data}');
      final msg = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      throw Exception(msg ?? 'Bookingni qabul qilishda xatolik');
    }
  }
}