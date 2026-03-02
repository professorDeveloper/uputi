
import '../../data/model/driver_model.dart';

abstract class DriverUserRemoteDataSource {
  Future<DriverUserModel> getUser();
}