import 'package:dio/dio.dart';
import '../../../../core/storage/shared_storage.dart';

abstract class CancelMyTripDataSource {
  Future<String> cancelMyTrip({required int tripId});
}

class CancelMyTripDataSourceImpl implements CancelMyTripDataSource {
  final Dio dio;
  CancelMyTripDataSourceImpl(this.dio);

  @override
  Future<String> cancelMyTrip({required int tripId}) async {
    final token = Prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Access token not found");
    }

    try {
      final res = await dio.delete(
        '/api/trips/$tripId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = res.data;

      if (data is Map<String, dynamic>) {
        return (data['message']?.toString()) ?? 'Trip canceled';
      }

      return data?.toString() ?? 'Trip canceled';
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message']?.toString())
          : e.response?.data?.toString();

      throw Exception(msg ?? 'Cancel failed');
    }
  }
}
