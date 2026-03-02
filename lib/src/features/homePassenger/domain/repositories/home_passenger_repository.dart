import '../../data/models/response/booking_model.dart';
import '../../data/models/response/driver_trip_model.dart';
import '../../data/models/response/my_trips_model.dart';
import '../../data/models/response/user_model.dart';

abstract class HomePassengerRepository {
  Future<UserModel> getUser();

  Future<String> cancelBooking({required int bookingId});

  Future<List<BookingModel>> getMyInProgressBookings();

  Future<MyTripsResponse> getMyTripsForPassenger();

  Future<String> cancelMyTrip({required int tripId});

  Future<TripsPage> getActiveTrips({
    int page = 1,
    int perPage = 10,
  });


  Future<String> createBooking({required int tripId, required int seats});

  Future<String> offerPrice({
    required int tripId,
    required int seats,
    required int offeredPrice,
    String? comment,
  });
}
