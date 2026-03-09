part of 'home_passenger_bloc.dart';

@immutable
sealed class HomePassengerEvent {}

class HomePassengerInit extends HomePassengerEvent {}

class HomePassengerSilentRefresh extends HomePassengerEvent {
  final bool isTab1;
   HomePassengerSilentRefresh({this.isTab1 = false});
}

class LoadMoreActiveTrips extends HomePassengerEvent {}

class CancelBookingPressed extends HomePassengerEvent {
  final int bookingId;
  CancelBookingPressed({required this.bookingId});
}

class CancelMyTripPressed extends HomePassengerEvent {
  final int tripId;
  CancelMyTripPressed({required this.tripId});
}

class OfferPriceRequested extends HomePassengerEvent {
  final int tripId;
  final int seats;
  final int offeredPrice;
  final String? comment;

  OfferPriceRequested({
    required this.tripId,
    required this.seats,
    required this.offeredPrice,
    this.comment,
  });
}

class CreateBookingRequested extends HomePassengerEvent {
  final int tripId;
  final int seats;

  CreateBookingRequested({
    required this.tripId,
    required this.seats,
  });
}

class MyTripsTabOpened extends HomePassengerEvent {}

class RefreshMyTripsPressed extends HomePassengerEvent {}

class CheckTelegramStatusRequested extends HomePassengerEvent {}