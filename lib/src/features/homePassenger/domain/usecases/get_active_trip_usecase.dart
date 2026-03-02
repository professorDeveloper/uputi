import '../../data/models/response/driver_trip_model.dart';
import '../repositories/home_passenger_repository.dart';

class GetActiveTripsUseCase {
  final HomePassengerRepository repository;

  GetActiveTripsUseCase(this.repository);

  Future<TripsPage> call({
    int page = 1,
    int perPage = 10,
  }) {
    return repository.getActiveTrips(
      page: page,
      perPage: perPage,
    );
  }
}
