
import '../repo/home_driver_repository.dart';

class CompleteTripUseCase {
  final HomeDriverRepository repository;
  CompleteTripUseCase(this.repository);
  Future<String> call({required int tripId}) =>
      repository.completeTrip(tripId: tripId);
}