// lib/src/features/searchDriver/presentation/blocs/driver_search_trips_state.dart

part of 'driver_search_trips_bloc.dart';

@immutable
sealed class DriverSearchTripsState {}

final class DriverSearchTripsInitial extends DriverSearchTripsState {}

final class DriverSearchTripsLoading extends DriverSearchTripsState {}

final class DriverSearchTripsLoaded extends DriverSearchTripsState {
  final SearchDriverRegionResponse response;

  final bool actionLoading;
  final String? actionMessage;
  final String? actionError;
  final bool paginationLoading;

  DriverSearchTripsLoaded({
    required this.response,
    this.actionLoading = false,
    this.actionMessage,
    this.actionError,
    this.paginationLoading = false,
  });

  DriverSearchTripsLoaded copyWith({
    SearchDriverRegionResponse? response,
    bool? actionLoading,
    String? actionMessage,
    String? actionError,
    bool? paginationLoading,
  }) {
    return DriverSearchTripsLoaded(
      response: response ?? this.response,
      actionLoading: actionLoading ?? this.actionLoading,
      actionMessage: actionMessage,
      actionError: actionError,
      paginationLoading: paginationLoading ?? this.paginationLoading,
    );
  }
}

final class DriverSearchTripsError extends DriverSearchTripsState {
  final String message;

  DriverSearchTripsError(this.message);
}