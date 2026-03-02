import '../repositories/home_passenger_repository.dart';

class CancelMyTripUseCase {
  final HomePassengerRepository repo;
  CancelMyTripUseCase(this.repo);

  Future<String> call({required int tripId}) => repo.cancelMyTrip(tripId: tripId);
}
