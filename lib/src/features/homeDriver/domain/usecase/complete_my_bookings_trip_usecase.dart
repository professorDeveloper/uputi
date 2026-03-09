
import '../repo/home_driver_repository.dart';

class CompleteMyBookingsTripUsecase {
  final HomeDriverRepository repository;
  CompleteMyBookingsTripUsecase(this.repository);
  Future<String> call({required int tripId}) =>
      repository.completeMyBookingTrip(tripId: tripId);
}