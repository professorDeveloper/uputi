import '../repositories/home_passenger_repository.dart';

class CancelBookingUseCase {
  final HomePassengerRepository repo;
  CancelBookingUseCase(this.repo);

  Future<String> call({required int bookingId}) {
    return repo.cancelBooking(bookingId: bookingId);
  }
}
