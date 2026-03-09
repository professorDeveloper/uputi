import '../../data/model/driver_booking_model.dart';
import '../../data/model/driver_model.dart';
import '../../data/model/driver_my_trips.dart';
import '../../data/model/driver_paggination.dart';

abstract class HomeDriverRepository {
  Future<DriverUserModel> getUser();

  Future<String> acceptBooking(int bookingId);
  Future<String> rejectBooking(int bookingId);


  Future<List<DriverBookingModel>> getMyInProgressBookings();

  Future<PassengerTripsPage> getActiveTrips({int page = 1, int perPage = 10});

  Future<DriverMyTripsResponse> getMyTrips();

  Future<String> createBooking({required int tripId});

  Future<String> cancelBooking(int bookingId);

  Future<String> completeTrip({required int tripId});
  Future<String> completeMyBookingTrip({required int tripId});
}
