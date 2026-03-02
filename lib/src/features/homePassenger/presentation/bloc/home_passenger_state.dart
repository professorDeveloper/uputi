part of 'home_passenger_bloc.dart';

@immutable
sealed class HomePassengerState {}

final class HomePassengerInitial extends HomePassengerState {}

final class HomePassengerLoading extends HomePassengerState {}

final class HomePassengerError extends HomePassengerState {
  final String message;
  HomePassengerError(this.message);
}

/// Boshqa qurilmadan kirish yoki token yaroqsiz
final class HomePassengerUnauthorized extends HomePassengerState {}

class HomePassengerLoaded extends HomePassengerState {
  final UserModel user;
  final List<BookingModel> inProgress;
  final List<DriverTripModel> trips;

  final int tripsNextPage;
  final bool tripsHasMore;
  final bool isTripsLoadingMore;

  final List<MyTripItem> myTrips;
  final bool isMyTripsLoading;
  final String? myTripsError;
  final bool myTripsLoadedOnce;

  final bool isCancelLoading;
  final String? cancelMessage;
  final String? cancelError;

  final bool isTripCancelLoading;
  final String? tripCancelMessage;
  final String? tripCancelError;

  final bool isCreateLoading;
  final String? createMessage;
  final String? createError;

  final bool isOfferLoading;
  final String? offerMessage;
  final String? offerError;

  HomePassengerLoaded({
    required this.user,
    required this.inProgress,
    required this.trips,

    // pagination defaults
    this.tripsNextPage = 2,
    this.tripsHasMore = true,
    this.isTripsLoadingMore = false,

    this.myTrips = const [],
    this.isMyTripsLoading = false,
    this.myTripsError,
    this.myTripsLoadedOnce = false,

    this.isCancelLoading = false,
    this.cancelMessage,
    this.cancelError,

    this.isTripCancelLoading = false,
    this.tripCancelMessage,
    this.tripCancelError,

    this.isCreateLoading = false,
    this.createMessage,
    this.createError,

    this.isOfferLoading = false,
    this.offerMessage,
    this.offerError,
  });

  HomePassengerLoaded copyWith({
    UserModel? user,
    List<BookingModel>? inProgress,
    List<DriverTripModel>? trips,

    int? tripsNextPage,
    bool? tripsHasMore,
    bool? isTripsLoadingMore,

    List<MyTripItem>? myTrips,
    bool? isMyTripsLoading,
    String? myTripsError,
    bool? myTripsLoadedOnce,

    bool? isCancelLoading,
    String? cancelMessage,
    String? cancelError,

    bool? isTripCancelLoading,
    String? tripCancelMessage,
    String? tripCancelError,

    bool? isCreateLoading,
    String? createMessage,
    String? createError,

    bool? isOfferLoading,
    String? offerMessage,
    String? offerError,
  }) {
    return HomePassengerLoaded(
      user: user ?? this.user,
      inProgress: inProgress ?? this.inProgress,
      trips: trips ?? this.trips,

      tripsNextPage: tripsNextPage ?? this.tripsNextPage,
      tripsHasMore: tripsHasMore ?? this.tripsHasMore,
      isTripsLoadingMore: isTripsLoadingMore ?? this.isTripsLoadingMore,

      myTrips: myTrips ?? this.myTrips,
      isMyTripsLoading: isMyTripsLoading ?? this.isMyTripsLoading,
      myTripsError: myTripsError,
      myTripsLoadedOnce: myTripsLoadedOnce ?? this.myTripsLoadedOnce,

      isCancelLoading: isCancelLoading ?? this.isCancelLoading,
      cancelMessage: cancelMessage,
      cancelError: cancelError,

      isTripCancelLoading: isTripCancelLoading ?? this.isTripCancelLoading,
      tripCancelMessage: tripCancelMessage,
      tripCancelError: tripCancelError,

      isCreateLoading: isCreateLoading ?? this.isCreateLoading,
      createMessage: createMessage,
      createError: createError,

      isOfferLoading: isOfferLoading ?? this.isOfferLoading,
      offerMessage: offerMessage,
      offerError: offerError,
    );
  }
}