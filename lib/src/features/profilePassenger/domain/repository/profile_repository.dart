import '../../data/model/profile_response.dart';

abstract class ProfileRepository {
  Future<ProfileResponse> getProfile();
}
