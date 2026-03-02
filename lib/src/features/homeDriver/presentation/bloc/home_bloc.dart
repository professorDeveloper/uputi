import 'package:easy_localization/easy_localization.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../data/model/driver_booking_model.dart';
import '../../data/model/driver_model.dart';
import '../../data/model/driver_my_trips.dart';
import '../../data/model/driver_paggination.dart';
import '../../domain/usecase/accept_booking_usecase.dart';
import '../../domain/usecase/cancel_booking_usecase.dart';
import '../../domain/usecase/complete_trip_usecase.dart';
import '../../domain/usecase/create_booking_usecase.dart';
import '../../domain/usecase/get_active_trips_usecase.dart';
import '../../domain/usecase/get_driver_booking_usecase.dart';
import '../../domain/usecase/get_driver_my_trips_usecase.dart';
import '../../domain/usecase/get_driver_usecase.dart';
import '../../domain/usecase/reject_booking_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeDriverBloc extends Bloc<HomeDriverEvent, HomeDriverState> {
  final GetDriverUserUseCase getUser;
  final GetDriverBookingsUseCase getBookings;
  final GetActiveDriverTripsUseCase getTrips;
  final CreateDriverBookingUseCase createBooking;
  final CancelDriverBookingUseCase cancelBooking;
  final CompleteTripUseCase completeTrip;
  final GetDriverMyTripsUseCase getMyTrips;
  final AcceptDriverBookingUseCase acceptBooking;
  final RejectDriverBookingUseCase rejectBooking;

  HomeDriverBloc({
    required this.getUser,
    required this.getBookings,
    required this.getTrips,
    required this.createBooking,
    required this.cancelBooking,
    required this.completeTrip,
    required this.getMyTrips,
    required this.acceptBooking,
    required this.rejectBooking,
  }) : super(HomeDriverInitial()) {
    on<HomeDriverInit>(_onInit);
    on<HomeDriverSilentRefresh>(_onSilentRefresh);
    on<LoadMoreActiveTrips>(_onLoadMoreTrips);
    on<DriverCreateBookingRequested>(_onCreateBooking);
    on<DriverCancelBookingPressed>(_onCancelBooking);
    on<DriverCompleteTripPressed>(_onCompleteTrip);
    on<DriverMyTripsTabOpened>(_onMyTripsTabOpened);
    on<DriverRefreshMyTripsPressed>(_onRefreshMyTrips);
    on<DriverAcceptBookingPressed>(_onAcceptBooking);
    on<DriverAcceptIncomingBookingPressed>(_onAcceptIncomingBooking);
    on<DriverRejectIncomingBookingPressed>(_onRejectIncomingBooking);
    on<HomeDriverUnauthenticated>((_, emit) => emit(HomeDriverUnauthorized()));
  }

  bool _silentRefreshing = false;

  bool _isUnauth(dynamic error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('unauthenticated') || msg.contains('401');
  }

  Future<void> _onInit(
      HomeDriverInit event,
      Emitter<HomeDriverState> emit,
      ) async {
    emit(HomeDriverLoading());
    try {
      final results = await Future.wait([
        getUser(),
        getBookings(),
        getTrips(page: 1, perPage: 10),
      ]);
      final tripsPage = results[2] as PassengerTripsPage;
      emit(HomeDriverLoaded(
        user: results[0] as DriverUserModel,
        inProgress: results[1] as List<DriverBookingModel>,
        trips: tripsPage.items,
        tripsNextPage: tripsPage.nextPage,
        tripsHasMore: tripsPage.hasMore,
        myTrips: const [],
        myTripsLoadedOnce: false,
      ));
    } catch (e, st) {

      emit(_isUnauth(e) ? HomeDriverUnauthorized() : HomeDriverError(e.toString()));
    }
  }

  Future<void> _onSilentRefresh(
      HomeDriverSilentRefresh event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;
    if (_silentRefreshing) return;
    _silentRefreshing = true;

    try {
      final futures = await Future.wait([
        getUser(),
        getBookings(),
        getTrips(page: 1, perPage: 10),
        if (s.myTripsLoadedOnce) getMyTrips() else Future.value(null),
      ]);

      final freshUser = futures[0] as DriverUserModel;
      final freshBookings = futures[1] as List<DriverBookingModel>;
      final freshPage = futures[2] as PassengerTripsPage;
      final freshMyTrips = futures[3] as DriverMyTripsResponse?;

      final mergedTrips = _merge<PassengerTripModel>(
        old: s.trips, fresh: freshPage.items, id: (x) => x.id,
      );
      final mergedBookings = _merge<DriverBookingModel>(
        old: s.inProgress, fresh: freshBookings, id: (x) => x.id!,
      );
      final mergedMyTrips = (s.myTripsLoadedOnce && freshMyTrips != null)
          ? _merge<DriverMyTripItem>(
        old: s.myTrips, fresh: freshMyTrips.items, id: (x) => x.id!,
      )
          : s.myTrips;

      emit(s.copyWith(
        user: freshUser,
        trips: mergedTrips,
        inProgress: mergedBookings,
        myTrips: mergedMyTrips,
        tripsNextPage: freshPage.nextPage,
        tripsHasMore: freshPage.hasMore,
        isTripsLoadingMore: false,
        cancelMessage: s.cancelMessage,
        cancelError: s.cancelError,
        createMessage: s.createMessage,
        createError: s.createError,
        completeMessage: s.completeMessage,
        completeError: s.completeError,
        myTripsError: s.myTripsError,
        acceptMessage: s.acceptMessage,
        acceptError: s.acceptError,
        rejectMessage: s.rejectMessage,
        rejectError: s.rejectError,
      ));
    } catch (e) {
      if (_isUnauth(e)) emit(HomeDriverUnauthorized());
    } finally {
      _silentRefreshing = false;
    }
  }

  Future<void> _onLoadMoreTrips(
      LoadMoreActiveTrips event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;
    if (!s.tripsHasMore || s.isTripsLoadingMore) return;

    emit(s.copyWith(isTripsLoadingMore: true));
    try {
      final page = await getTrips(page: s.tripsNextPage, perPage: 10);
      final existingIds = s.trips.map((e) => e.id).toSet();
      final newItems = page.items.where((e) => !existingIds.contains(e.id)).toList();
      emit(s.copyWith(
        trips: [...s.trips, ...newItems],
        tripsNextPage: page.nextPage,
        tripsHasMore: page.hasMore,
        isTripsLoadingMore: false,
      ));
    } catch (e) {
      if (_isUnauth(e)) {
        emit(HomeDriverUnauthorized());
      } else {
        emit(s.copyWith(isTripsLoadingMore: false));
      }
    }
  }

  Future<void> _onCreateBooking(
      DriverCreateBookingRequested event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;

    emit(s.copyWith(isCreateLoading: true, createMessage: null, createError: null));
    try {
      final msg = await createBooking(tripId: event.tripId);
      final refreshed = await _refreshAll(s);
      emit(refreshed.copyWith(isCreateLoading: false, createMessage: msg));
    } catch (e) {

      if (_isUnauth(e)) {
        emit(HomeDriverUnauthorized());
      } else {
        emit(s.copyWith(isCreateLoading: false, createError: e.toString()));
      }
    }
  }

  Future<void> _onCancelBooking(
      DriverCancelBookingPressed event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;

    emit(s.copyWith(isCancelLoading: true, cancelMessage: null, cancelError: null));
    try {
      final msg = await cancelBooking(bookingId: event.bookingId);
      final refreshed = await _refreshAll(s);
      emit(refreshed.copyWith(isCancelLoading: false, cancelMessage: msg));
    } catch (e, st) {

      if (_isUnauth(e)) {
        emit(HomeDriverUnauthorized());
      } else {
        emit(s.copyWith(isCancelLoading: false, cancelError: e.toString()));
      }
    }
  }

  Future<void> _onCompleteTrip(
      DriverCompleteTripPressed event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;

    emit(s.copyWith(isCompleteLoading: true, completeMessage: null, completeError: null));
    try {
      final msg = await completeTrip(tripId: event.tripId);
      final refreshed = await _refreshAll(s);
      emit(refreshed.copyWith(isCompleteLoading: false, completeMessage: msg));
    } catch (e, st) {

      if (_isUnauth(e)) {
        emit(HomeDriverUnauthorized());
      } else {
        emit(s.copyWith(isCompleteLoading: false, completeError: e.toString()));
      }
    }
  }

  Future<void> _onAcceptIncomingBooking(
      DriverAcceptIncomingBookingPressed event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;

    emit(s.copyWith(isAcceptLoading: true, acceptMessage: null, acceptError: null));
    try {
      final msg = await acceptBooking(bookingId: event.bookingId);
      final refreshed = await _refreshAll(s);
      emit(refreshed.copyWith(isAcceptLoading: false, acceptMessage: msg));
    } catch (e, st) {

      if (_isUnauth(e)) {
        emit(HomeDriverUnauthorized());
      } else {
        emit(s.copyWith(isAcceptLoading: false, acceptError: e.toString()));
      }
    }
  }

  Future<void> _onRejectIncomingBooking(
      DriverRejectIncomingBookingPressed event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;

    emit(s.copyWith(isRejectLoading: true, rejectMessage: null, rejectError: null));
    try {
      final msg = await rejectBooking(bookingId: event.bookingId);
      final refreshed = await _refreshAll(s);
      emit(refreshed.copyWith(isRejectLoading: false, rejectMessage: msg));
    } catch (e, st) {

      if (_isUnauth(e)) {
        emit(HomeDriverUnauthorized());
      } else {
        emit(s.copyWith(isRejectLoading: false, rejectError: e.toString()));
      }
    }
  }

  Future<void> _onMyTripsTabOpened(
      DriverMyTripsTabOpened event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;
    if (s.isMyTripsLoading) return;

    emit(s.copyWith(
      isMyTripsLoading: true,
      myTripsError: null,
    ));

    try {
      final res = await getMyTrips();
      final current = state;
      if (current is! HomeDriverLoaded) return;

      emit(current.copyWith(
        myTrips: res.items,
        isMyTripsLoading: false,
        myTripsLoadedOnce: true,
      ));
    } catch (e) {

      if (_isUnauth(e)) {
        emit(HomeDriverUnauthorized());
      } else {
        final current = state;
        if (current is HomeDriverLoaded) {
          emit(current.copyWith(
            isMyTripsLoading: false,
            myTripsError: e.toString(),
          ));
        }
      }
    }
  }

  Future<void> _onRefreshMyTrips(
      DriverRefreshMyTripsPressed event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;
    if (s.isMyTripsLoading) return;

    emit(s.copyWith(isMyTripsLoading: true, myTripsError: null));

    try {
      final res = await getMyTrips();
      final current = state;
      if (current is! HomeDriverLoaded) return;

      emit(current.copyWith(
        myTrips: res.items,
        isMyTripsLoading: false,
        myTripsLoadedOnce: true,
      ));
    } catch (e, st) {

      if (_isUnauth(e)) {
        emit(HomeDriverUnauthorized());
      } else {
        final current = state;
        if (current is HomeDriverLoaded) {
          emit(current.copyWith(
            isMyTripsLoading: false,
            myTripsError: e.toString(),
          ));
        }
      }
    }
  }

  Future<void> _onAcceptBooking(
      DriverAcceptBookingPressed event,
      Emitter<HomeDriverState> emit,
      ) async {
    final s = state;
    if (s is! HomeDriverLoaded) return;

    emit(s.copyWith(isCreateLoading: true, createMessage: null, createError: null));
    try {
      final refreshed = await _refreshAll(s);
      emit(refreshed.copyWith(isCreateLoading: false, createMessage: 'booking_status_accepted'.tr()));
    } catch (e, st) {

      if (_isUnauth(e)) {
        emit(HomeDriverUnauthorized());
      } else {
        emit(s.copyWith(isCreateLoading: false, createError: e.toString()));
      }
    }
  }

  Future<HomeDriverLoaded> _refreshAll(HomeDriverLoaded s) async {
    final results = await Future.wait([
      getUser(),
      getBookings(),
      getTrips(page: 1, perPage: 10),
    ]);
    final tripsPage = results[2] as PassengerTripsPage;

    List<DriverMyTripItem> myTrips = s.myTrips;
    if (s.myTripsLoadedOnce) {
      try {
        myTrips = (await getMyTrips()).items;
      } catch (_) {}
    }

    return s.copyWith(
      user: results[0] as DriverUserModel,
      inProgress: results[1] as List<DriverBookingModel>,
      trips: tripsPage.items,
      tripsNextPage: tripsPage.nextPage,
      tripsHasMore: tripsPage.hasMore,
      isTripsLoadingMore: false,
      myTrips: myTrips,
    );
  }

  List<T> _merge<T>({
    required List<T> old,
    required List<T> fresh,
    required int Function(T) id,
  }) {
    final freshMap = <int, T>{for (final x in fresh) id(x): x};
    final used = <int>{};
    final result = <T>[];
    for (final o in old) {
      final k = id(o);
      result.add(freshMap[k] ?? o);
      used.add(k);
    }
    for (final f in fresh) {
      if (!used.contains(id(f))) result.add(f);
    }
    return result;
  }
}