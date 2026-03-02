import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:uputi/src/features/homePassenger/data/models/response/my_trips_model.dart';
import '../../../../core/storage/shared_storage.dart';
import '../models/response/booking_model.dart';


import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/storage/shared_storage.dart';
import 'my_trip_datasource.dart';
class MyTripsDataSourceImpl implements MyTripsDataSource {
  final Dio dio;

  MyTripsDataSourceImpl(this.dio);

  @override
  Future<MyTripsResponse> getMyTripsForPassenger() async {
    final token = Prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Access token not found");
    }

    try {
      final res = await dio.get(
        '/api/trips/for/passenger/my',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.json,
        ),
      );

      debugPrint("MY TRIPS RAW: ${res.data}");

      dynamic raw = res.data;

      // Ba'zan string bo'lib kelib qolsa
      if (raw is String) {
        raw = jsonDecode(raw);
      }

      // Ba'zan {data: [...]} bo'lib qolsa
      if (raw is Map && raw['data'] is List) {
        raw = raw['data'];
      }

      if (raw is! List) {
        throw const FormatException("Invalid /my response format (expected List)");
      }

      return MyTripsResponse.fromJsonList(raw);
    } on DioException catch (e) {
      final data = e.response?.data;

      String? msg;
      if (data is Map && data['message'] != null) {
        msg = data['message']?.toString();
      }

      debugPrint("MY TRIPS ERROR: $data");
      throw Exception(msg ?? 'Get my trips failed');
    }
  }
}
