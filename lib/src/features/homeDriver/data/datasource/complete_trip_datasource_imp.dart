import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../domain/ds/complete_trip_datasource.dart';

class CompleteTripDataSourceImpl implements CompleteTripDataSource {
  final Dio dio;

  CompleteTripDataSourceImpl(this.dio);

  @override
  Future<String> completeTrip({required int tripId}) async {
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.put(
        '/api/trips/$tripId/completedIntercity',
        data: {},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return res.data['message']?.toString() ?? 'Trip yakunlandi';
    } on DioException catch (e) {
      debugPrint('Complete trip URL: ${e.requestOptions.uri}');
      debugPrint('Complete trip STATUS: ${e.response?.statusCode}');
      debugPrint('Complete trip BODY: ${e.response?.data}');
      final msg = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      throw Exception(msg ?? 'Tripni yakunlashda xatolik');
    }
  }

  @override
  Future<String> completeTripMyBookings({required int tripId}) async{
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.put(
        '/api/trips/$tripId/completed',
        data: {},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return res.data['message']?.toString() ?? 'Trip yakunlandi';
    } on DioException catch (e) {
      debugPrint('Complete trip URL: ${e.requestOptions.uri}');
      debugPrint('Complete trip STATUS: ${e.response?.statusCode}');
      debugPrint('Complete trip BODY: ${e.response?.data}');
      final msg = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      throw Exception(msg ?? 'Tripni yakunlashda xatolik');
    }
  }
}
