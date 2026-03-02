abstract class CreateBookingDataSource {
  Future<String> createBooking({
    required int tripId,
    required int seats,
  });
}
