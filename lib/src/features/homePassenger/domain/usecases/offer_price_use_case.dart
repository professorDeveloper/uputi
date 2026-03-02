
import 'package:uputi/src/features/homePassenger/domain/repositories/home_passenger_repository.dart';

class OfferPriceUseCase {
  final HomePassengerRepository repo;
  OfferPriceUseCase(this.repo);

  Future<String> call({
    required int tripId,
    required int seats,
    required int offeredPrice,
    String? comment,
  }) {
    return repo.offerPrice(
      tripId: tripId,
      seats: seats,
      offeredPrice: offeredPrice,
      comment: comment,
    );
  }
}
