import 'package:uputi/src/features/searchPassenger/data/models/search_city_trip_response.dart';

import '../repositories/search_passenger_repository.dart';

class SearchTripsByLocationUsecase {
  final SearchPassengerRepository repository;

  SearchTripsByLocationUsecase(this.repository);

  Future<CityLocationSearchResponse> call({
    required double latitude,
    required double longitude,
  }) {
    return repository.searchByCity(latitude: latitude, longitude: longitude);
  }
}
