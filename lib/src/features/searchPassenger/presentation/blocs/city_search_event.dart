// city_search_event.dart
part of 'city_search_bloc.dart';

@immutable
sealed class CitySearchEvent {}

final class CitySearchRequested extends CitySearchEvent {
  final double lat;
  final double lng;
  CitySearchRequested({required this.lat, required this.lng});
}

final class CitySearchRefreshed extends CitySearchEvent {}

final class CitySearchCleared extends CitySearchEvent {}
