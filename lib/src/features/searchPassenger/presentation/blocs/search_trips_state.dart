part of 'search_trips_bloc.dart';

@immutable
sealed class SearchTripsState {}

final class SearchTripsInitial extends SearchTripsState {}

final class SearchTripsLoading extends SearchTripsState {}

final class SearchTripsLoaded extends SearchTripsState {
  final SearchRegionTripResponse response;

  final bool actionLoading;
  final String? actionMessage;
  final String? actionError;

  SearchTripsLoaded({
    required this.response,
    this.actionLoading = false,
    this.actionMessage,
    this.actionError,
  });

  SearchTripsLoaded copyWith({
    SearchRegionTripResponse? response,
    bool? actionLoading,
    String? actionMessage,
    String? actionError,
  }) {
    return SearchTripsLoaded(
      response: response ?? this.response,
      actionLoading: actionLoading ?? this.actionLoading,
      actionMessage: actionMessage,
      actionError: actionError,
    );
  }
}

final class SearchTripsError extends SearchTripsState {
  final String message;

  SearchTripsError(this.message);
}
