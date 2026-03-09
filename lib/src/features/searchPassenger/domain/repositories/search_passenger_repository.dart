import 'package:uputi/src/features/searchPassenger/data/models/search_city_trip_response.dart';

import '../../data/models/search_region_trip_response.dart';

abstract class SearchPassengerRepository {
  Future<SearchRegionTripResponse> searchTrips({
    required String from,
    required String to,
    String? date, // optiona// l
    int? page, // optiona// l

  });

  Future<CityLocationSearchResponse> searchByCity({
    required double latitude,
    required double longitude,
  });
}
