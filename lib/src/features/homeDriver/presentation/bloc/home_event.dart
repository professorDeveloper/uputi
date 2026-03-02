import 'package:flutter/cupertino.dart';

@immutable
sealed class HomeDriverEvent {}

class HomeDriverInit extends HomeDriverEvent {}

class HomeDriverSilentRefresh extends HomeDriverEvent {}

class LoadMoreActiveTrips extends HomeDriverEvent {}

class DriverCreateBookingRequested extends HomeDriverEvent {
  final int tripId;
  DriverCreateBookingRequested({required this.tripId});
}

class DriverCancelBookingPressed extends HomeDriverEvent {
  final int bookingId;
  DriverCancelBookingPressed({required this.bookingId});
}

class DriverCompleteTripPressed extends HomeDriverEvent {
  final int tripId;
  DriverCompleteTripPressed({required this.tripId});
}

class DriverMyTripsTabOpened extends HomeDriverEvent {}

class DriverRefreshMyTripsPressed extends HomeDriverEvent {}

class HomeDriverUnauthenticated extends HomeDriverEvent {}

/// Driver boshqa yo'lovchining tripiga booking yuboradi (aktiv triplar ro'yxatidan)
class DriverAcceptBookingPressed extends HomeDriverEvent {
  final int bookingId;
  DriverAcceptBookingPressed({required this.bookingId});
}

/// Driver o'z tripiga kelgan bookingni QABUL QILADI
class DriverAcceptIncomingBookingPressed extends HomeDriverEvent {
  final int bookingId;
  DriverAcceptIncomingBookingPressed({required this.bookingId});
}

/// Driver o'z tripiga kelgan bookingni RAD ETADI (delete)
class DriverRejectIncomingBookingPressed extends HomeDriverEvent {
  final int bookingId;
  DriverRejectIncomingBookingPressed({required this.bookingId});
}