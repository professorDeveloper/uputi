import 'package:uputi/src/features/homePassenger/data/datasources/cancel_mytrip_datasource.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/cancel_trip_data_source.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/create_booking_data_source.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/offered_price_data_source.dart';

import '../../data/datasources/get_user_data_source.dart';
import '../../data/datasources/home_passenger_data_source.dart';
import '../../data/datasources/in_progress_data_source.dart';
import '../../data/datasources/my_trip_datasource.dart';
import '../../data/datasources/my_trips_datasource_imp.dart';
import '../../data/models/response/booking_model.dart';
import '../../data/models/response/driver_trip_model.dart';
import '../../data/models/response/my_trips_model.dart';
import '../../data/models/response/user_model.dart';
import 'home_passenger_repository.dart';

class HomePassengerRepositoryImpl implements HomePassengerRepository {
  final UserRemoteDataSource userDS;
  final BookingRemoteDataSource bookingDS;
  final CancelMyTripDataSource cancelMyTripDs;
  final HomePassengerDataSource tripsDS;
  final CancelTripDataSource cancelTripDS;
  final CreateBookingDataSource createBookingDS;
  final MyTripsDataSource passengersTripDs;
  final OfferPriceDataSource offerPriceDataSource;

  HomePassengerRepositoryImpl({
    required this.passengersTripDs,
    required this.userDS,
    required this.bookingDS,
    required this.cancelTripDS,
    required this.offerPriceDataSource,
    required this.tripsDS,
    required this.createBookingDS,
    required this.cancelMyTripDs,
  });

  @override
  Future<String> cancelMyTrip({required int tripId}) {
    return cancelMyTripDs.cancelMyTrip(tripId: tripId);
  }

  @override
  Future<UserModel> getUser() {
    return userDS.getUser();
  }

  @override
  Future<String> offerPrice({
    required int tripId,
    required int seats,
    required int offeredPrice,
    String? comment,
  }) {
    return offerPriceDataSource.offerPrice(
      tripId: tripId,
      seats: seats,
      offeredPrice: offeredPrice,
      comment: comment,
    );
  }

  @override
  Future<List<BookingModel>> getMyInProgressBookings() {
    return bookingDS.getMyInProgressBookings();
  }


  @override
  Future<String> createBooking({required int tripId, required int seats}) {
    return createBookingDS.createBooking(tripId: tripId, seats: seats);
  }

  @override
  Future<String> cancelBooking({required int bookingId}) {
    return cancelTripDS.cancelBooking(bookingId);
  }

  @override
  Future<MyTripsResponse> getMyTripsForPassenger() {
    return passengersTripDs.getMyTripsForPassenger();
  }

  @override
  Future<TripsPage> getActiveTrips({int page = 1, int perPage = 10}) {
    return  tripsDS.getActiveTrips(page: page, perPage: perPage);
  }


}
