
import '../../data/model/driver_my_trips.dart';

abstract class DriverMyTripsDataSource {
  Future<DriverMyTripsResponse> getMyTrips();

}