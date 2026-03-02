import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../domain/ds/reject_booking_datasource.dart';

class RejectDriverBookingDataSourceImpl
    implements RejectDriverBookingDataSource {
  final Dio dio;

  RejectDriverBookingDataSourceImpl(this.dio);

  @override
  Future<String> rejectBooking(int bookingId) async {
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.post(
        '/api/bookings/$bookingId/delete',
        data: {},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('Reject booking RESPONSE: ${res.data}');
      return res.data['message']?.toString() ?? 'Booking rad etildi';
    } on DioException catch (e) {
      debugPrint('Reject booking URL: ${e.requestOptions.uri}');
      debugPrint('Reject booking STATUS: ${e.response?.statusCode}');
      debugPrint('Reject booking BODY: ${e.response?.data}');
      final msg = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      throw Exception(msg ?? 'Bookingni rad etishda xatolik');
    }
  }
}