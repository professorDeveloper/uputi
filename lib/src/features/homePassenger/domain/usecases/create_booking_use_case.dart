import '../repositories/home_passenger_repository.dart';

class CreateBookingUseCase {
  final HomePassengerRepository repository;

  CreateBookingUseCase(this.repository);

  Future<String> call({
    required int tripId,
    required int seats,
  }) {
    return repository.createBooking(
      tripId: tripId,
      seats: seats,
    );
  }
}
