import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/storage/shared_storage.dart';
import '../models/passenger_history_response.dart';
import 'fetch_history_datasource.dart';

class FetchHistoryDataSourceImpl implements FetchHistoryDataSource {
  final Dio dio;
  FetchHistoryDataSourceImpl(this.dio);

  @override
  Future<PassengerHistoryResponse> fetchPassengerHistory({
    required int type,
    int page = 1,
  }) async {
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.get(
        '/api/passenger/history/$type',
        queryParameters: {'page': page},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return PassengerHistoryResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('STATUS: ${e.response?.statusCode}');
      debugPrint('BODY: ${e.response?.data}');
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
