// lib/src/features/searchDriver/presentation/blocs/driver_search_trips_event.dart

part of 'driver_search_trips_bloc.dart';

@immutable
sealed class DriverSearchTripsEvent {}

final class DriverSearchTripsRequested extends DriverSearchTripsEvent {
  final String from;
  final String to;
  final String? date;

  DriverSearchTripsRequested({
    required this.from,
    required this.to,
    this.date,
  });
}

final class DriverSearchCreateBookingRequested extends DriverSearchTripsEvent {
  final int tripId;

  DriverSearchCreateBookingRequested({required this.tripId});
}