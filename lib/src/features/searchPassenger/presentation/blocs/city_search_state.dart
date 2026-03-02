// city_search_state.dart
part of 'city_search_bloc.dart';

@immutable
sealed class CitySearchState {}

final class CitySearchInitial extends CitySearchState {}

final class CitySearchLoading extends CitySearchState {}

final class CitySearchError extends CitySearchState {
  final String message;
  CitySearchError({required this.message});
}

final class CitySearchLoaded extends CitySearchState {
  final CityLocationSearchResponse response;

  final double lastLat;
  final double lastLng;

  final bool isRefreshing;
  final String? errorMessage;

  CitySearchLoaded({
    required this.response,
    required this.lastLat,
    required this.lastLng,
    this.isRefreshing = false,
    this.errorMessage,
  });

  CitySearchLoaded copyWith({
    CityLocationSearchResponse? response,
    double? lastLat,
    double? lastLng,
    bool? isRefreshing,
    String? errorMessage, // null berilsa ham yoziladi
  }) {
    return CitySearchLoaded(
      response: response ?? this.response,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }
}
