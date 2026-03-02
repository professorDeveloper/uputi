
import '../entities/picked_place.dart';

abstract class CreateTripRepository {
  Future<PickedPlace> reverseGeocode({
    required double lat,
    required double lng,
    String language = 'uz',
  });
  Future<Map<String, dynamic>> createTrip({
    required double fromLat,
    required double fromLng,
    required String fromAddress,
    required double toLat,
    required double toLng,
    required String toAddress,
    required String date,
    required String time,
    required int seats,
    required int amount,
    required String role,
  });

}
