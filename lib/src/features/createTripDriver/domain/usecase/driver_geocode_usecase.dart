
import '../../../createTrip/domain/entities/picked_place.dart';
import '../repo/driver_create_trip_repo.dart';

class DriverReverseGeocodeUseCase {
  final DriverCreateTripRepository repo;
  DriverReverseGeocodeUseCase(this.repo);

  Future<PickedPlace> call({
    required double lat,
    required double lng,
    String language = 'uz',
  }) {
    return repo.reverseGeocode(lat: lat, lng: lng, language: language);
  }
}