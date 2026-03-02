import '../../data/models/auth_start_response.dart';
import '../../data/models/auth_verify_response.dart';
import '../../data/models/role_update_response.dart';

abstract class AuthRepository {
  Future<AuthStartResponse> startAuth({
    required String name,
    required String phone,
  });
  Future<RoleUpdateResponse> updateRole(String role);


  Future<AuthVerifyResponse> verifyAuth({
    required String verificationId,
    required String code,
  });
}
