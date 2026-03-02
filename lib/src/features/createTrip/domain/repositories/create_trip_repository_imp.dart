import 'package:dio/dio.dart';

import '../../data/datasources/geo_code_data_source.dart';
import '../../data/datasources/trip_remote_datasource.dart';
import '../../domain/entities/picked_place.dart';
import '../../domain/repositories/create_trip_repository.dart';

class CreateTripRepositoryImpl implements CreateTripRepository {
  final GeoCodeDataSource geo;
  final TripRemoteDataSource remote;

  CreateTripRepositoryImpl(this.geo,this.remote);

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
  Future<Map<String, dynamic>> createTrip({
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
    required String role,
  }) {
    return remote.createTrip(
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
