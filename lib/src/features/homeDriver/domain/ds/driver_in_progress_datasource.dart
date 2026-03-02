
import '../../data/model/driver_booking_model.dart';

abstract class DriverInProgressDataSource {
  Future<List<DriverBookingModel>> getMyInProgressBookings();
}