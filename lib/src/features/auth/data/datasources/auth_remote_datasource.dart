import 'package:dio/dio.dart';
import 'package:uputi/src/features/auth/data/models/auth_verify_response.dart';
import 'package:uputi/src/features/auth/data/models/role_update_request.dart';
import 'package:uputi/src/features/auth/data/models/role_update_response.dart';
import '../models/auth_start_request.dart';
import '../models/auth_start_response.dart';
import '../models/auth_verify_request.dart';

abstract class AuthRemoteDataSource {
  Future<AuthStartResponse> start(AuthStartRequest request);
  Future<RoleUpdateResponse> updateRole(RoleUpdateRequest request);
  Future<AuthVerifyResponse> verify(AuthVerifyRequest request);
}

