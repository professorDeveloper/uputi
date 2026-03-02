// lib/src/features/searchDriver/domain/usecases/search_driver_by_location_usecase.dart

import '../../../searchPassenger/data/models/search_city_trip_response.dart';
import '../repo/search_repository.dart';

class SearchDriverByLocationUseCase {
  final SearchDriverRepository repository;

  SearchDriverByLocationUseCase(this.repository);

  Future<CityLocationSearchResponse> call({
    required double latitude,
    required double longitude,
  }) {
    return repository.searchByLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
