import '../../data/models/role_update_response.dart';
import '../repositories/auth_repository.dart';

class UpdateRoleUseCase {
  final AuthRepository repo;
  UpdateRoleUseCase(this.repo);

  Future<RoleUpdateResponse> call({required String role}) {
    return repo.updateRole(role);
  }
}
