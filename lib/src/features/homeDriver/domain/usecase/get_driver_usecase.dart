import '../../data/model/driver_model.dart';
import '../repo/home_driver_repository.dart';

class GetDriverUserUseCase {
  final HomeDriverRepository repository;
  GetDriverUserUseCase(this.repository);
  Future<DriverUserModel> call() => repository.getUser();
}