import 'package:uputi/src/features/profilePassenger/data/datasources/get_profile_response_datasource.dart';
import 'package:uputi/src/features/profilePassenger/data/model/profile_response.dart';
import 'package:uputi/src/features/profilePassenger/domain/repository/profile_repository.dart';

class ProfileRepositoryImp implements ProfileRepository {
  ProfileRepositoryImp({required this.dataSource});

  final GetProfileResponseDatasource dataSource;

  @override
  Future<ProfileResponse> getProfile() {
    return dataSource.getProfileResponse();
  }
}
