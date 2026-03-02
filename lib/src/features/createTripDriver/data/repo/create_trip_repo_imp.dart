import '../../../createTrip/data/datasources/geo_code_data_source.dart';
import '../../../createTrip/domain/entities/picked_place.dart';
import '../../domain/ds/trip_remote_datasource.dart';
import '../../domain/repo/driver_create_trip_repo.dart';

class DriverCreateTripRepositoryImpl implements DriverCreateTripRepository {
  final GeoCodeDataSource geo;
  final DriverTripRemoteDataSource remote;

  DriverCreateTripRepositoryImpl(this.geo, this.remote);

  @override
  Future<PickedPlace> reverseGeocode({
    required double lat,
    required double lng,
    String language = 'uz',
  }) async {
    final res = await geo.reverseGeocode(
      lat: lat,
      lng: lng,
      language: language,
    );
    return PickedPlace(
      lat: lat,
      lng: lng,
      address: res.displayName,
      countryCode: res.countryCode,
    );
  }

  @override
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
  }) {
    return remote.createDriverTrip(
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
