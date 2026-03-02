import 'package:uputi/src/features/profilePassenger/data/model/profile_response.dart';

abstract class GetProfileResponseDatasource {
  Future<ProfileResponse> getProfileResponse();
}
