// lib/src/features/searchDriver/presentation/blocs/driver_city_search_event.dart

part of 'driver_city_search_bloc.dart';

@immutable
sealed class DriverCitySearchEvent {}

final class DriverCitySearchRequested extends DriverCitySearchEvent {
  final double lat;
  final double lng;
  DriverCitySearchRequested({required this.lat, required this.lng});
}

final class DriverCitySearchRefreshed extends DriverCitySearchEvent {}

final class DriverCitySearchCleared extends DriverCitySearchEvent {}