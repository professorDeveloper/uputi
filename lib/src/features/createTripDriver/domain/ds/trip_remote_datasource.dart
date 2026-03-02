abstract class DriverTripRemoteDataSource {
  Future<Map<String, dynamic>> createDriverTrip({
    required double fromLat,
    required double fromLng,
    required String fromAddress,
    required double toLat,
    required double toLng,
    required String toAddress,
    required String date,
    required String time,
    required int seats,
    required int amount,
    String? comment,
  });
}
