
import '../../data/model/driver_booking_model.dart';
import '../repo/home_driver_repository.dart';

class GetDriverBookingsUseCase {
  final HomeDriverRepository repository;
  GetDriverBookingsUseCase(this.repository);
  Future<List<DriverBookingModel>> call() =>
      repository.getMyInProgressBookings();
}