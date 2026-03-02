// lib/src/features/searchDriver/presentation/blocs/driver_city_search_state.dart

part of 'driver_city_search_bloc.dart';

@immutable
sealed class DriverCitySearchState {}

final class DriverCitySearchInitial extends DriverCitySearchState {}

final class DriverCitySearchLoading extends DriverCitySearchState {}

final class DriverCitySearchError extends DriverCitySearchState {
  final String message;
  DriverCitySearchError({required this.message});
}

final class DriverCitySearchLoaded extends DriverCitySearchState {
  final CityLocationSearchResponse response;

  final double lastLat;
  final double lastLng;

  final bool isRefreshing;
  final String? errorMessage;

  DriverCitySearchLoaded({
    required this.response,
    required this.lastLat,
    required this.lastLng,
    this.isRefreshing = false,
    this.errorMessage,
  });

  DriverCitySearchLoaded copyWith({
    CityLocationSearchResponse? response,
    double? lastLat,
    double? lastLng,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return DriverCitySearchLoaded(
      response: response ?? this.response,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }
}