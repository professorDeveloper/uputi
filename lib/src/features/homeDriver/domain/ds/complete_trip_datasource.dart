abstract class CompleteTripDataSource {
  Future<String> completeTrip({required int tripId});
  Future<String> completeTripMyBookings({required int tripId});
}