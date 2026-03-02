abstract class OfferPriceDataSource {
  Future<String> offerPrice({
    required int tripId,
    required int seats,
    required int offeredPrice,
    String? comment,
  });
}
