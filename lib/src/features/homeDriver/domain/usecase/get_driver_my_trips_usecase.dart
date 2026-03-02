import '../../data/model/driver_my_trips.dart';
import '../repo/home_driver_repository.dart';

class GetDriverMyTripsUseCase {
  final HomeDriverRepository repository;
  GetDriverMyTripsUseCase(this.repository);
  Future<DriverMyTripsResponse> call() => repository.getMyTrips();
}