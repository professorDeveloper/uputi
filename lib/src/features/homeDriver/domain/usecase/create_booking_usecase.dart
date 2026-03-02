import '../repo/home_driver_repository.dart';

class CreateDriverBookingUseCase {
  final HomeDriverRepository repository;
  CreateDriverBookingUseCase(this.repository);
  Future<String> call({required int tripId}) =>
      repository.createBooking(tripId: tripId);
}