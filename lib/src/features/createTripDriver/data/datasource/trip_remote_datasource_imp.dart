import 'package:dio/dio.dart';
import 'package:uputi/src/core/storage/shared_storage.dart';

import '../../domain/ds/trip_remote_datasource.dart';

class DriverTripRemoteDataSourceImpl implements DriverTripRemoteDataSource {
  final Dio dio;

  DriverTripRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> createDriverTrip({
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
    String? comment,
  }) async {
    final token = Prefs.getAccessToken();

    final body = <String, dynamic>{
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
      "role": "driver",
    };

    // comment faqat bo'sh bo'lmasa qo'shiladi
    if (comment != null && comment.trim().isNotEmpty) {
      body["comment"] = comment.trim();
    }

    final res = await dio.post(
      '/api/trips',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
      data: body,
    );

    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Invalid response');
  }
}
