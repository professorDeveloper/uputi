
import '../models/response/my_trips_model.dart';

abstract class MyTripsDataSource {
  Future<MyTripsResponse> getMyTripsForPassenger();
}
