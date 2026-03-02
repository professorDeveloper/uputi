import 'package:uputi/src/features/homeDriver/domain/ds/accept_booking_datasource.dart';
import 'package:uputi/src/features/homeDriver/domain/ds/reject_booking_datasource.dart';

import '../../domain/ds/cancel_booking_driver_datasource.dart';
import '../../domain/ds/complete_trip_datasource.dart';
import '../../domain/ds/create_booking_driver_datasource.dart';
import '../../domain/ds/driver_active_trips_datasource.dart';
import '../../domain/ds/driver_in_progress_datasource.dart';
import '../../domain/ds/driver_my_trips_datasource.dart';
import '../../domain/ds/driver_user_datasource.dart';
import '../../domain/repo/home_driver_repository.dart';
import '../model/driver_booking_model.dart';
import '../model/driver_model.dart';
import '../model/driver_my_trips.dart';
import '../model/driver_paggination.dart';

class HomeDriverRepositoryImpl implements HomeDriverRepository {
  final DriverUserRemoteDataSource userDS;
  final DriverInProgressDataSource inProgressDS;
  final HomeDriverDataSource tripsDS;
  final AcceptDriverBookingDataSource acceptBookingDS;
  final RejectDriverBookingDataSource rejectBookingDs;
  final DriverMyTripsDataSource myTripsDS;
  final CreateDriverBookingDataSource createBookingDS;
  final CancelDriverBookingDataSource cancelBookingDS;
  final CompleteTripDataSource completeTripDS;

  HomeDriverRepositoryImpl({
    required this.userDS,
    required this.inProgressDS,
    required this.tripsDS,
    required this.acceptBookingDS,
    required this.rejectBookingDs,
    required this.myTripsDS,
    required this.createBookingDS,
    required this.cancelBookingDS,
    required this.completeTripDS,
  });

  @override
  Future<DriverUserModel> getUser() => userDS.getUser();

  @override
  Future<List<DriverBookingModel>> getMyInProgressBookings() =>
      inProgressDS.getMyInProgressBookings();

  @override
  Future<PassengerTripsPage> getActiveTrips({int page = 1, int perPage = 10}) =>
      tripsDS.getActiveTrips(page: page, perPage: perPage);

  @override
  Future<DriverMyTripsResponse> getMyTrips() => myTripsDS.getMyTrips();

  @override
  Future<String> createBooking({required int tripId}) =>
      createBookingDS.createBooking(tripId: tripId);

  @override
  Future<String> cancelBooking(int bookingId) async =>
      cancelBookingDS.cancelBooking(bookingId);

  @override
  Future<String> completeTrip({required int tripId}) =>
      completeTripDS.completeTrip(tripId: tripId);

  @override
  Future<String> acceptBooking(int bookingId) =>
      acceptBookingDS.acceptBooking(bookingId);

  @override
  Future<String> rejectBooking(int bookingId) =>
      rejectBookingDs.rejectBooking(bookingId);
}
