import '../../data/entities/search_driver_region_response.dart';
import '../repo/search_repository.dart';

class SearchDriverPassengersUseCase {
  final SearchDriverRepository repository;

  SearchDriverPassengersUseCase(this.repository);

  Future<SearchDriverRegionResponse> call({
    required String from,
    required String to,
    String? date,
  }) {
    return repository.searchPassengers(from: from, to: to, date: date);
  }
}