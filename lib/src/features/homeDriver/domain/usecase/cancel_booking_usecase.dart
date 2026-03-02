
import '../repo/home_driver_repository.dart';

class CancelDriverBookingUseCase {
  final HomeDriverRepository repository;
  CancelDriverBookingUseCase(this.repository);
  Future<String> call({required int bookingId}) =>
      repository.cancelBooking(bookingId);
}