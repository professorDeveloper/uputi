import 'package:dio/dio.dart';
import 'package:uputi/src/core/network/dio_error.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_start_request.dart';
import '../../data/models/auth_start_response.dart';
import '../../data/models/auth_verify_request.dart';
import '../../data/models/auth_verify_response.dart';
import '../../data/models/role_update_request.dart';
import '../../data/models/role_update_response.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<AuthVerifyResponse> verifyAuth({
    required String verificationId,
    required String code,
  }) async {
    try {
      return await remote.verify(
        AuthVerifyRequest(verificationId: verificationId, code: code),
      );
    } on DioException catch (e) {
      return AuthVerifyResponse(message: e.messageToUser);
    } on FormatException catch (e) {
      return AuthVerifyResponse(message: e.message);
    } catch (_) {
      return const AuthVerifyResponse(message: "Kutilmagan xatolik");
    }
  }

  @override
  Future<RoleUpdateResponse> updateRole(String role) async {
    try {
      return await remote.updateRole(RoleUpdateRequest(role: role));
    } on DioException catch (e) {
      return RoleUpdateResponse(message: e.messageToUser, role: "");
    } on FormatException catch (e) {
      return RoleUpdateResponse(message: e.message, role: "");
    } catch (_) {
      return const RoleUpdateResponse(message: "Kutilmagan xatolik", role: "");
    }
  }

  @override
  Future<AuthStartResponse> startAuth({
    required String name,
    required String phone,
  }) async {
    try {
      return await remote.start(AuthStartRequest(name: name, phone: phone));
    } on DioException catch (e) {
      return AuthStartResponse(message: e.messageToUser, verificationId: "");
    } on FormatException catch (e) {
      return AuthStartResponse(message: e.message, verificationId: "");
    } catch (_) {
      return AuthStartResponse(
        message: "Kutilmagan xatolik",
        verificationId: "",
      );
    }
  }
}
