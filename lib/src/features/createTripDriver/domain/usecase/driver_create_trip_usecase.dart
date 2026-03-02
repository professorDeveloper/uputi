import '../repo/driver_create_trip_repo.dart';

class DriverCreateTripUseCase {
  final DriverCreateTripRepository repo;
  DriverCreateTripUseCase(this.repo);

  Future<Map<String, dynamic>> call({
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
  }) {
    return repo.createDriverTrip(
      fromLat: fromLat,
      fromLng: fromLng,
      fromAddress: fromAddress,
      toLat: toLat,
      toLng: toLng,
      toAddress: toAddress,
      date: date,
      time: time,
      seats: seats,
      amount: amount,
      comment: comment,
    );
  }
}