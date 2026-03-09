import 'package:flutter/cupertino.dart';

import '../../data/model/driver_booking_model.dart';
import '../../data/model/driver_model.dart';
import '../../data/model/driver_my_trips.dart';
import '../../data/model/driver_paggination.dart';

@immutable
sealed class HomeDriverState {}

final class HomeDriverInitial extends HomeDriverState {}

final class HomeDriverLoading extends HomeDriverState {}

final class HomeDriverError extends HomeDriverState {
  final String message;
  HomeDriverError(this.message);
}

final class HomeDriverUnauthorized extends HomeDriverState {}

class HomeDriverLoaded extends HomeDriverState {
  final DriverUserModel user;
  final List<DriverBookingModel> inProgress;
  final List<PassengerTripModel> trips;

  final int tripsNextPage;
  final bool tripsHasMore;
  final bool isTripsLoadingMore;

  final List<DriverMyTripItem> myTrips;
  final bool isMyTripsLoading;
  final String? myTripsError;
  final bool myTripsLoadedOnce;

  final bool isCreateLoading;
  final String? createMessage;
  final String? createError;

  final bool isCancelLoading;
  final String? cancelMessage;
  final String? cancelError;

  final bool isCompleteLoading;
  final String? completeMessage;
  final String? completeError;

  // ── Incoming booking: qabul qilish / rad etish ───────────────────────────
  final bool isAcceptLoading;
  final String? acceptMessage;
  final String? acceptError;

  final bool isRejectLoading;
  final String? rejectMessage;
  final String? rejectError;

  HomeDriverLoaded({
    required this.user,
    required this.inProgress,
    required this.trips,
    this.tripsNextPage = 2,
    this.tripsHasMore = true,
    this.isTripsLoadingMore = false,
    this.myTrips = const [],
    this.isMyTripsLoading = false,
    this.myTripsError,
    this.myTripsLoadedOnce = false,
    this.isCreateLoading = false,
    this.createMessage,
    this.createError,
    this.isCancelLoading = false,
    this.cancelMessage,
    this.cancelError,
    this.isCompleteLoading = false,
    this.completeMessage,
    this.completeError,
    this.isAcceptLoading = false,
    this.acceptMessage,
    this.acceptError,
    this.isRejectLoading = false,
    this.rejectMessage,
    this.rejectError,
  });

  HomeDriverLoaded copyWith({
    DriverUserModel? user,
    List<DriverBookingModel>? inProgress,
    List<PassengerTripModel>? trips,
    int? tripsNextPage,
    bool? tripsHasMore,
    bool? isTripsLoadingMore,
    List<DriverMyTripItem>? myTrips,
    bool? isMyTripsLoading,
    String? myTripsError,
    bool? myTripsLoadedOnce,
    bool? isCreateLoading,
    String? createMessage,
    String? createError,
    bool? isCancelLoading,
    String? cancelMessage,
    String? cancelError,
    bool? isCompleteLoading,
    String? completeMessage,
    String? completeError,
    bool? isAcceptLoading,
    String? acceptMessage,
    String? acceptError,
    bool? isRejectLoading,
    String? rejectMessage,
    String? rejectError,
  }) {
    return HomeDriverLoaded(
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
      isCreateLoading: isCreateLoading ?? this.isCreateLoading,
      createMessage: createMessage,
      createError: createError,
      isCancelLoading: isCancelLoading ?? this.isCancelLoading,
      cancelMessage: cancelMessage,
      cancelError: cancelError,
      isCompleteLoading: isCompleteLoading ?? this.isCompleteLoading,
      completeMessage: completeMessage,
      completeError: completeError,
      isAcceptLoading: isAcceptLoading ?? this.isAcceptLoading,
      acceptMessage: acceptMessage,
      acceptError: acceptError,
      isRejectLoading: isRejectLoading ?? this.isRejectLoading,
      rejectMessage: rejectMessage,
      rejectError: rejectError,
    );
  }
}