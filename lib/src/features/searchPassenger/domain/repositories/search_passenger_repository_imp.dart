import 'package:uputi/src/features/searchPassenger/data/models/search_city_trip_response.dart';

import '../../data/datasources/filter_in_citys_datasource.dart';
import '../../data/datasources/filter_in_religions_datasource.dart';
import '../../data/models/search_region_trip_response.dart';
import 'search_passenger_repository.dart';

class SearchPassengerRepositoryImp implements SearchPassengerRepository {
  final TripsSearchRemoteDataSource remoteDataSource;
  final CityTripsRemoteDataSource cityTripsRemoteDataSource;

  SearchPassengerRepositoryImp(
    this.remoteDataSource,
    this.cityTripsRemoteDataSource,
  );

  @override
  Future<SearchRegionTripResponse> searchTrips({
    required String from,
    required String to,
    String? date,
  }) async {
    try {
      return await remoteDataSource.searchTrips(from: from, to: to, date: date);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CityLocationSearchResponse> searchByCity({
    required double latitude,
    required double longitude,
  }) {
    try {
      return cityTripsRemoteDataSource.searchByLocation(
        lat: latitude,
        lng: longitude,
      );
    } catch (e) {
      rethrow;
    }
  }
}
