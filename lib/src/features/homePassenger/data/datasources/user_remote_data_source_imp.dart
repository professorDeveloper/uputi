import 'package:dio/dio.dart';
import '../../../../core/storage/shared_storage.dart';
import '../models/response/user_model.dart';
import 'get_user_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> getUser() async {
    final token = Prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Access token not found");
    }

    try {
      final res = await dio.get(
        '/api/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (res.data is! Map<String, dynamic>) {
        throw const FormatException("Invalid user response format");
      }

      return UserModel.fromJson(res.data);
    }

    on DioException catch (e) {
      throw _mapDioError(e);
    }

    on FormatException catch (e) {
      throw Exception(e.message);
    }

    catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Exception _mapDioError(DioException e) {
    // Timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception("Serverga ulanish vaqti tugadi");
    }

    if (e.type == DioExceptionType.connectionError) {
      return Exception("Internet aloqasi yo‘q");
    }

    if (e.response != null) {
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        // Laravel / backend message
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return Exception(message);
        }
      }

      return Exception(
        "Server error (${e.response!.statusCode})",
      );
    }

    return Exception("Noma’lum tarmoq xatosi");
  }
}
