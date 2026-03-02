part of 'search_trips_bloc.dart';

@immutable
sealed class SearchTripsEvent {}

final class SearchTripsRequested extends SearchTripsEvent {
  final String from;
  final String to;
  final String? date;

  SearchTripsRequested({
    required this.from,
    required this.to,
    this.date,
  });
}

final class SearchTripsCreateBookingRequested extends SearchTripsEvent {
  final int tripId;
  final int seats;

  SearchTripsCreateBookingRequested({
    required this.tripId,
    required this.seats,
  });
}

final class SearchTripsOfferPriceRequested extends SearchTripsEvent {
  final int tripId;
  final int seats;
  final int offeredPrice;
  final String? comment;

  SearchTripsOfferPriceRequested({
    required this.tripId,
    required this.seats,
    required this.offeredPrice,
    this.comment,
  });
}
