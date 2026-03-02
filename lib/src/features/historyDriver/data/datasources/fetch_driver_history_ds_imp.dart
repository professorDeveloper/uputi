import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uputi/src/features/historyDriver/data/models/driver_history_resposne.dart';

import '../../../../core/storage/shared_storage.dart';
import '../../domain/ds/fetch_driver_history_datasource.dart';

class FetchDriverHistoryDataSourceImpl implements FetchDriverHistoryDataSource {
  final Dio dio;

  FetchDriverHistoryDataSourceImpl(this.dio);

  @override
  Future<DriverHistoryResponse> fetchDriverHistory({
    required int type,
    int page = 1,
  }) async {
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.get(
        '/api/driver/history/$type',
        queryParameters: {'page': page},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint(
        '[DriverHistory] type=$type page=$page status=${res.statusCode}',
      );

      final data = res.data;
      if (data is! Map) {
        debugPrint(
          '[DriverHistory] Unexpected response type: ${data.runtimeType}',
        );
        throw Exception('Unexpected response format');
      }

      try {
        return DriverHistoryResponse.fromJson(data as Map<String, dynamic>);
      } catch (parseErr) {
        // Parse xatosi — raw response ni log qilamiz
        debugPrint('[DriverHistory] PARSE ERROR: $parseErr');
        debugPrint('[DriverHistory] Raw response: $data');
        rethrow;
      }
    } on DioException catch (e) {
      debugPrint('[DriverHistory] DioError URL: ${e.requestOptions.uri}');
      debugPrint('[DriverHistory] STATUS: ${e.response?.statusCode}');
      debugPrint('[DriverHistory] BODY: ${e.response?.data}');
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
