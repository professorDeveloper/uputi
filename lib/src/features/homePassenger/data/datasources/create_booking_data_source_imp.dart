import 'package:dio/dio.dart';

import '../../../../core/storage/shared_storage.dart';
import 'create_booking_data_source.dart';

class CreateBookingDataSourceImpl implements CreateBookingDataSource {
  final Dio dio;

  CreateBookingDataSourceImpl(this.dio);

  @override
  Future<String> createBooking({
    required int tripId,
    required int seats,
  }) async {
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.post(
        '/api/bookings/for/passenger',
        data: {
          'trip_id': tripId,
          'seats': seats,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return res.data['message'] ?? 'Booking created';
    } on DioException catch (e) {
      print(e.response?.data['message']);
      throw Exception(
        e.response?.data['message'] ?? 'Booking failed',
      );
    }
  }
}
