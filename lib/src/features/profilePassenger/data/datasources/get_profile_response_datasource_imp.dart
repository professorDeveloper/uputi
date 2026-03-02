import 'package:dio/dio.dart';
import 'package:uputi/src/features/profilePassenger/data/datasources/get_profile_response_datasource.dart';
import 'package:uputi/src/features/profilePassenger/data/model/profile_response.dart';

import '../../../../core/storage/shared_storage.dart';

class GetProfileResponseDatasourceImp extends GetProfileResponseDatasource {
  final Dio dio;

  GetProfileResponseDatasourceImp(this.dio);

  @override
  Future<ProfileResponse> getProfileResponse() async {
    final token = Prefs.getAccessToken();

    try {
      final res = await dio.get(
        '/api/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = res.data;

      if (data is Map<String, dynamic>) {
        return ProfileResponse.fromJson(data);
      }

      if (data is Map) {
        return ProfileResponse.fromJson(Map<String, dynamic>.from(data));
      }

      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: 'Unexpected response type: ${data.runtimeType}',
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/user'),
        type: DioExceptionType.unknown,
        error: e,
      );
    }
  }
}
