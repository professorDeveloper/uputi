import 'package:dio/dio.dart';
import '../../../../core/storage/shared_storage.dart';
import 'offered_price_data_source.dart';

class OfferPriceDataSourceImpl implements OfferPriceDataSource {
  final Dio dio;
  OfferPriceDataSourceImpl(this.dio);

  @override
  Future<String> offerPrice({
    required int tripId,
    required int seats,
    required int offeredPrice,
    String? comment,
  }) async {
    final token = Prefs.getAccessToken();

    final data = <String, dynamic>{
      "trip_id": tripId,
      "seats": seats,
      "offered_price": offeredPrice,
    };

    if (comment != null && comment.trim().isNotEmpty) {
      data["comment"] = comment.trim();
    }

    final res = await dio.post(
      "/api/bookings/for/passenger",
      data: data,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final body = res.data;
    if (body is Map && body["message"] != null) {
      return body["message"].toString();
    }
    return "OK";
  }
}

