// lib/src/features/searchDriver/data/repositories/search_driver_repository_impl.dart

import '../../../searchPassenger/data/models/search_city_trip_response.dart';
import '../../domain/repo/search_repository.dart';
import '../ds/city_search_datasource.dart';
import '../ds/region_search_datasource.dart';
import '../entities/search_driver_region_response.dart';

class SearchDriverRepositoryImpl implements SearchDriverRepository {
  final DriverRegionSearchRemoteDataSource regionDs;
  final DriverCitySearchRemoteDataSource cityDs;

  SearchDriverRepositoryImpl(this.regionDs, this.cityDs);

  @override
  Future<SearchDriverRegionResponse> searchPassengers({
    required String from,
    required String to,
    String? date,
    int? page,
  }) {
    return regionDs.searchPassengers(from: from, to: to, date: date, page: page);
  }

  @override
  Future<CityLocationSearchResponse> searchByLocation({
    required double latitude,
    required double longitude,
  }) {
    return cityDs.searchByLocation(lat: latitude, lng: longitude);
  }
}