import 'package:dio/dio.dart';
import '../../../../core/storage/shared_storage.dart';
import '../models/response/driver_trip_model.dart';
import 'home_passenger_data_source.dart';

class HomePassengerDataSourceImpl implements HomePassengerDataSource {
  final Dio dio;

  HomePassengerDataSourceImpl(this.dio);

  @override
  Future<TripsPage> getActiveTrips({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final token = Prefs.getAccessToken();
      final response = await dio.get(
        '/api/trips/for/passenger/active',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: {
          "page": page,
          "per_page": perPage,
        },
      );

      if (response.data is! Map) {
        throw const FormatException("Unexpected response: not a JSON object");
      }

      final data = Map<String, dynamic>.from(response.data as Map);

      return TripsPage.fromJson(data);
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = (d is Map && d['message'] != null)
          ? d['message'].toString()
          : 'Failed to load trips';
      throw Exception(msg);
    }
  }
}
