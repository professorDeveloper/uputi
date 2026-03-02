
import '../models/response/driver_trip_model.dart';

abstract class HomePassengerDataSource {
  Future<TripsPage> getActiveTrips({
    int page = 1,
    int perPage = 10,
  });
}
