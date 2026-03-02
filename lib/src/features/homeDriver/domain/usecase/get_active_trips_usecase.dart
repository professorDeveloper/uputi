
import '../../data/model/driver_paggination.dart';
import '../repo/home_driver_repository.dart';

class GetActiveDriverTripsUseCase {
  final HomeDriverRepository repository;
  GetActiveDriverTripsUseCase(this.repository);
  Future<PassengerTripsPage> call({int page = 1, int perPage = 10}) =>
      repository.getActiveTrips(page: page, perPage: perPage);
}