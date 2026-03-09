// lib/src/features/searchDriver/data/datasources/driver_region_search_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/storage/shared_storage.dart';
import '../entities/search_driver_region_response.dart';

abstract class DriverRegionSearchRemoteDataSource {
  Future<SearchDriverRegionResponse> searchPassengers({
    required String from,
    required String to,
    String? date,
    int? page,
  });
}

class DriverRegionSearchRemoteDataSourceImpl
    implements DriverRegionSearchRemoteDataSource {
  final Dio dio;

  DriverRegionSearchRemoteDataSourceImpl(this.dio);

  @override
  Future<SearchDriverRegionResponse> searchPassengers({
    required String from,
    required String to,
    String? date,
    int? page,
  }) async {
    final token = Prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Access token not found");
    }

    try {
      final query = <String, dynamic>{'from': from, 'to': to};
      if (date != null && date.trim().isNotEmpty) {
        query['date'] = date.trim();
      }
      if (page != null && page > 1) {
        query['page'] = page;
      }

      final res = await dio.get(
        '/api/trips/passengers/address/search',
        queryParameters: query,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint("Driver region search response: ${res.data}");

      if (res.data is! Map<String, dynamic>) {
        throw const FormatException("Invalid response format");
      }

      return SearchDriverRegionResponse.fromJson(
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
        if (message is String && message.isNotEmpty) {
          return Exception(message);
        }
      }
      return Exception("Server error (${e.response!.statusCode})");
    }
    return Exception("Noma'lum tarmoq xatosi");
  }
}