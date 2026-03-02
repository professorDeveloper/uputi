// lib/src/features/searchDriver/data/datasources/driver_city_search_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/storage/shared_storage.dart';
import '../../../searchPassenger/data/models/search_city_trip_response.dart';

abstract class DriverCitySearchRemoteDataSource {
  Future<CityLocationSearchResponse> searchByLocation({
    required double lat,
    required double lng,
  });
}

class DriverCitySearchRemoteDataSourceImpl
    implements DriverCitySearchRemoteDataSource {
  final Dio dio;

  DriverCitySearchRemoteDataSourceImpl(this.dio);

  @override
  Future<CityLocationSearchResponse> searchByLocation({
    required double lat,
    required double lng,
  }) async {
    final token = Prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Access token not found");
    }

    try {
      final res = await dio.get(
        '/api/trips/passengers/location/search',
        queryParameters: {'lat': lat, 'lng': lng},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint("Driver city search response: ${res.data}");

      if (res.data is! Map<String, dynamic>) {
        throw const FormatException("Invalid response format");
      }

      return CityLocationSearchResponse.fromJson(
        res.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    } on FormatException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception("Serverga ulanish vaqti tugadi");
    }
    if (e.type == DioExceptionType.connectionError) {
      return Exception("Internet aloqasi yo'q");
    }
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) return Exception(message);
      }
      return Exception("Server error (${e.response!.statusCode})");
    }
    return Exception("Noma'lum tarmoq xatosi");
  }
}