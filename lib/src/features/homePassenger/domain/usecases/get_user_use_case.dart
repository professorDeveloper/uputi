import '../../data/models/response/user_model.dart';
import '../repositories/home_passenger_repository.dart';

class GetUserUseCase {
  final HomePassengerRepository repository;

  GetUserUseCase(this.repository);

  Future<UserModel> call() {
    return repository.getUser();
  }
}
