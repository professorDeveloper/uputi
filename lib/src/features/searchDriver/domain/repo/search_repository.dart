// lib/src/features/searchDriver/domain/repositories/search_driver_repository.dart

import '../../../searchPassenger/data/models/search_city_trip_response.dart';
import '../../data/entities/search_driver_region_response.dart';

abstract class SearchDriverRepository {
  Future<SearchDriverRegionResponse> searchPassengers({
    required String from,
    required String to,
    String? date,
  });

  Future<CityLocationSearchResponse> searchByLocation({
    required double latitude,
    required double longitude,
  });
}