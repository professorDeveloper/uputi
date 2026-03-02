import 'package:dio/dio.dart';
import '../models/responses/geocode_result.dart';

abstract class GeoCodeDataSource {
  Future<ReverseGeocodeResponse> reverseGeocode({
    required double lat,
    required double lng,
    String language = 'uz',
  });
}

class GeoCodeDataSourceImpl implements GeoCodeDataSource {
  final Dio dio;
  GeoCodeDataSourceImpl(this.dio);

  @override
  Future<ReverseGeocodeResponse> reverseGeocode({
    required double lat,
    required double lng,
    String language = 'uz',
  }) async {
    final res = await dio.get(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {
        'format': 'json',
        'lat': lat,
        'lon': lng,
        'accept-language': language,
      },
      options: Options(
        headers: {
          'accept': 'application/json',
          'User-Agent': 'uputi_flutter_app',
          'Referer': 'https://www.uputi.net/',
        },
      ),
    );

    return ReverseGeocodeResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
