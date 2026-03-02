import '../models/response/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<BookingModel>> getMyInProgressBookings();
}
