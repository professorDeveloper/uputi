import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../domain/ds/driver_my_trips_datasource.dart';
import '../model/driver_my_trips.dart';

class DriverMyTripsDataSourceImpl implements DriverMyTripsDataSource {
  final Dio dio;

  DriverMyTripsDataSourceImpl(this.dio);

  @override
  Future<DriverMyTripsResponse> getMyTrips() async {
    final token = Prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Access token not found");
    }

    try {
      final res = await dio.get(
        '/api/trips/my',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.json,
        ),
      );

      debugPrint("Driver my trips RAW: ${res.data}");

      dynamic raw = res.data;

      if (raw is String) raw = jsonDecode(raw);

      if (raw is Map && raw['data'] is List) raw = raw['data'];

      if (raw is! List) {
        throw const FormatException(
            "Invalid /api/trips/my response format (expected List)");
      }

      return DriverMyTripsResponse.fromJsonList(raw);
    } on DioException catch (e) {
      final data = e.response?.data;
      String? msg;
      if (data is Map && data['message'] != null) {
        msg = data['message']?.toString();
      }
      debugPrint("Driver my trips ERROR: $data");
      throw Exception(msg ?? 'Get my trips failed');
    }
  }
}