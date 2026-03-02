import '../../data/models/auth_start_response.dart';
import '../repositories/auth_repository.dart';

class StartAuthUseCase {
  final AuthRepository repo;
  StartAuthUseCase(this.repo);

  Future<AuthStartResponse> call({
    required String name,
    required String phone,
  }) {
    return repo.startAuth(name: name, phone: phone);
  }
}
