import '../repositories/home_passenger_repository.dart';
import '../../data/models/response/booking_model.dart';

class GetMyBookingsUseCase {
  final HomePassengerRepository repository;

  GetMyBookingsUseCase(this.repository);

  Future<List<BookingModel>> call() {
    return repository.getMyInProgressBookings();
  }
}
