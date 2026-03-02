import '../../data/models/auth_verify_response.dart';
import '../repositories/auth_repository.dart';

class VerifyAuthUseCase {
  final AuthRepository repo;
  VerifyAuthUseCase(this.repo);

  Future<AuthVerifyResponse> call({
    required String verificationId,
    required String code,
  }) {
    return repo.verifyAuth(verificationId: verificationId, code: code);
  }
}
