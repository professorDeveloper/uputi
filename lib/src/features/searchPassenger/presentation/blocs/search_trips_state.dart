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

  /// true while loading the next page (load more)
  final bool paginationLoading;

  SearchTripsLoaded({
    required this.response,
    this.actionLoading = false,
    this.actionMessage,
    this.actionError,
    this.paginationLoading = false,
  });

  SearchTripsLoaded copyWith({
    SearchRegionTripResponse? response,
    bool? actionLoading,
    String? actionMessage,
    String? actionError,
    bool? paginationLoading,
  }) {
    return SearchTripsLoaded(
      response: response ?? this.response,
      actionLoading: actionLoading ?? this.actionLoading,
      actionMessage: actionMessage,
      actionError: actionError,
      paginationLoading: paginationLoading ?? this.paginationLoading,
    );
  }
}

final class SearchTripsError extends SearchTripsState {
  final String message;

  SearchTripsError(this.message);
}