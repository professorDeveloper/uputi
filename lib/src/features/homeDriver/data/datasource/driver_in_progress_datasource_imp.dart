import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/shared_storage.dart';
import '../../domain/ds/driver_in_progress_datasource.dart';
import '../model/driver_booking_model.dart';

class DriverInProgressDataSourceImpl implements DriverInProgressDataSource {
  final Dio dio;

  DriverInProgressDataSourceImpl(this.dio);

  @override
  Future<List<DriverBookingModel>> getMyInProgressBookings() async {
    final token = Prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Access token not found");
    }

    try {
      final res = await dio.get(
        '/api/bookings/my/in-progress',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint("Driver in-progress bookings: ${res.data}");
      debugPrint("Driver in-progress type: ${res.data.runtimeType}");

      if (res.data is! List) {
        return [];
      }

      return (res.data as List)
          .map((e) => DriverBookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
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