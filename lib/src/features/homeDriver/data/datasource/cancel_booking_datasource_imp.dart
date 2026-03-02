import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../domain/ds/cancel_booking_driver_datasource.dart';

class CancelDriverBookingDataSourceImpl
    implements CancelDriverBookingDataSource {
  final Dio dio;

  CancelDriverBookingDataSourceImpl(this.dio);

  @override
  Future<String> cancelBooking(int bookingId) async {
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.post(
        '/api/bookings/$bookingId/cancel',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data['message']?.toString() ?? 'Bekor qilindi';
    } on DioException catch (e) {
      debugPrint('Cancel URL: ${e.requestOptions.uri}');
      debugPrint('Cancel STATUS: ${e.response?.statusCode}');
      debugPrint('Cancel BODY: ${e.response?.data}');
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
