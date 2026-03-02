import 'package:dio/dio.dart';
import '../models/auth_start_request.dart';
import '../models/auth_start_response.dart';
import '../models/auth_verify_request.dart';
import '../models/auth_verify_response.dart';
import '../models/role_update_request.dart';
import '../models/role_update_response.dart';
import 'auth_remote_datasource.dart';
import '../../../../core/storage/shared_storage.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthStartResponse> start(AuthStartRequest request) async {
    final res = await dio.post("/api/auth/start", data: request.toJson());
    final data = res.data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final parsed = AuthStartResponse.fromJson(map);

      if (parsed.isLoggedIn) {
        await Prefs.setAccessToken(parsed.accessToken!);

        dio.options.headers["Authorization"] =
            "${parsed.tokenType ?? "Bearer"} ${parsed.accessToken}";
      }

      return parsed;
    }

    throw const FormatException("Unexpected response");
  }

  @override
  Future<AuthVerifyResponse> verify(AuthVerifyRequest request) async {
    final res = await dio.post("/api/auth/verify", data: request.toJson());
    final data = res.data;

    if (data is Map<String, dynamic>) {
      return AuthVerifyResponse.fromJson(data);
    }

    throw const FormatException("Unexpected response");
  }

  @override
  Future<RoleUpdateResponse> updateRole(RoleUpdateRequest request) async {
    final token = Prefs.getAccessToken() ?? "";

    final res = await dio.post(
      "/api/role/update",
      data: request.toJson(),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return RoleUpdateResponse.fromJson(data);
    }

    throw const FormatException("Unexpected response");
  }
}
