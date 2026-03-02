import 'package:uputi/src/features/profilePassenger/data/model/profile_response.dart';

import '../repository/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repo);

  final ProfileRepository _repo;

  Future<ProfileResponse> call() {
    return _repo.getProfile();
  }
}
