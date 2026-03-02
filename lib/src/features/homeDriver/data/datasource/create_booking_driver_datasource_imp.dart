import 'package:dio/dio.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../domain/ds/create_booking_driver_datasource.dart';

class CreateDriverBookingDataSourceImpl
    implements CreateDriverBookingDataSource {
  final Dio dio;

  CreateDriverBookingDataSourceImpl(this.dio);

  @override
  Future<String> createBooking({required int tripId}) async {
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.post(
        '/api/bookings',
        data: {'trip_id': tripId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return res.data['message']?.toString() ?? 'Booking yaratildi';
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Booking yaratishda xatolik',
      );
    }
  }
}
