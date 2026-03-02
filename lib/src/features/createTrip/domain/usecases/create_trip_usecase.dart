import '../repositories/create_trip_repository.dart';

class CreateTripUseCase {
  final CreateTripRepository repo;
  CreateTripUseCase(this.repo);

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
    String role = 'passenger',
  }) {
    return repo.createTrip(
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
      role: role,
    );
  }
}
