import 'package:dio/dio.dart';

import '../../../../core/storage/shared_storage.dart';

abstract class TripRemoteDataSource {
  Future<Map<String, dynamic>> createTrip({
    required double fromLat,
    required double fromLng,
    required String fromAddress,
    required double toLat,
    required double toLng,
    required String toAddress,
    required String date,
    required String time,
    required int seats,
    required int amount,
    required String role,
  });
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;

  TripRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> createTrip({
    required double fromLat,
    required double fromLng,
    required String fromAddress,
    required double toLat,
    required double toLng,
    required String toAddress,
    required String date,
    required String time,
    required int seats,
    required int amount,
    required String role,
  }) async {
    final token = Prefs.getAccessToken();

    final res = await dio.post(
      '/api/trips',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
      data: {
        "from_lat": fromLat,
        "from_lng": fromLng,
        "from_address": fromAddress,
        "to_lat": toLat,
        "to_lng": toLng,
        "to_address": toAddress,
        "date": date,
        "time": time,
        "seats": seats,
        "amount": amount,
        "role": role,
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Invalid response');
  }
}
