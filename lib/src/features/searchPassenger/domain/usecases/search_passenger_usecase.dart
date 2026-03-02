import '../../data/models/search_region_trip_response.dart';
import '../repositories/search_passenger_repository.dart';

class SearchPassengerUseCase {
  final SearchPassengerRepository repository;

  SearchPassengerUseCase(this.repository);

  Future<SearchRegionTripResponse> call({
    required String from,
    required String to,
    String? date, // optional
  }) {
    return repository.searchTrips(from: from, to: to, date: date);
  }
}
