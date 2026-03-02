
import '../../data/model/driver_paggination.dart';

abstract class HomeDriverDataSource {
  Future<PassengerTripsPage> getActiveTrips({
    int page = 1,
    int perPage = 10,
  });
}