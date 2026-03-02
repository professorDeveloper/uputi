
import '../repo/home_driver_repository.dart';

class AcceptDriverBookingUseCase {
  final HomeDriverRepository repository;
  AcceptDriverBookingUseCase(this.repository);
  Future<String> call({required int bookingId}) =>
      repository.acceptBooking(bookingId);
}