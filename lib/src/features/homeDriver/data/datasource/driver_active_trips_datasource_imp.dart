import 'package:dio/dio.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../domain/ds/driver_active_trips_datasource.dart';
import '../model/driver_paggination.dart';

class HomeDriverDataSourceImpl implements HomeDriverDataSource {
  final Dio dio;

  HomeDriverDataSourceImpl(this.dio);

  @override
  Future<PassengerTripsPage> getActiveTrips({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final token = Prefs.getAccessToken();
      final response = await dio.get(
        '/api/trips/active',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: {"page": page, "per_page": perPage},
      );

      if (response.data is! Map) {
        throw const FormatException("Unexpected response: not a JSON object");
      }

      final data = Map<String, dynamic>.from(response.data as Map);
      return PassengerTripsPage.fromJson(data);
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = (d is Map && d['message'] != null)
          ? d['message'].toString()
          : 'Failed to load trips';
      throw Exception(msg);
    }
  }
}
