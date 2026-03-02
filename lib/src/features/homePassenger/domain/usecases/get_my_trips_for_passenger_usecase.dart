import '../../data/models/response/my_trips_model.dart';
import '../repositories/home_passenger_repository.dart';
import '../../data/models/response/booking_model.dart';

class GetMyTripsForPassengerUseCase {
  final HomePassengerRepository repo;
  GetMyTripsForPassengerUseCase(this.repo);

  Future<MyTripsResponse> call() => repo.getMyTripsForPassenger();
}
