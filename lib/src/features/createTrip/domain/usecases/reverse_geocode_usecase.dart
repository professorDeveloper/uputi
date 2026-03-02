import '../entities/picked_place.dart';
import '../repositories/create_trip_repository.dart';

class ReverseGeocodeUseCase {
  final CreateTripRepository repo;
  ReverseGeocodeUseCase(this.repo);

  Future<PickedPlace> call({
    required double lat,
    required double lng,
    String language = 'uz',
  }) {
    return repo.reverseGeocode(lat: lat, lng: lng, language: language);
  }
}
