import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/storage/shared_storage.dart';
import 'cancel_trip_data_source.dart';

class CancelTripDataSourceImpl implements CancelTripDataSource {
  final Dio dio;

  CancelTripDataSourceImpl(this.dio);

  @override
  Future<String> cancelBooking(int bookingId) async {
    print('CancelBooking Booking ID: $bookingId');
    final token = Prefs.getAccessToken();
    print("Token ${token}");
    try {
      final res = await dio.post(
        '/api/bookings/$bookingId/for/passengers/cancel',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data['message']?.toString() ?? 'Cancelled';
    } on DioException catch (e) {
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('STATUS: ${e.response?.statusCode}');
      debugPrint('BODY: ${e.response?.data}');
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
