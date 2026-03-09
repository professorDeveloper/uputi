import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../data/models/response/booking_model.dart';
import '../../data/models/response/driver_trip_model.dart';
import '../../data/models/response/user_model.dart';
import '../../data/models/response/my_trips_model.dart';

import '../../domain/usecases/cancel_booking_use_case.dart';
import '../../domain/usecases/cancel_my_trip_usecase.dart';
import '../../domain/usecases/get_active_trip_usecase.dart';
import '../../domain/usecases/get_my_bookings_usecase.dart';
import '../../domain/usecases/get_my_trips_for_passenger_usecase.dart';
import '../../domain/usecases/get_user_use_case.dart';
import '../../domain/usecases/offer_price_use_case.dart';
import '../../domain/usecases/create_booking_use_case.dart';

part 'home_passenger_event.dart';

part 'home_passenger_state.dart';

class HomePassengerBloc extends Bloc<HomePassengerEvent, HomePassengerState> {
  final GetUserUseCase getUser;
  final GetMyBookingsUseCase getBookings;
  final GetActiveTripsUseCase getTrips;
  final CancelBookingUseCase cancelBooking;
  final CreateBookingUseCase createBooking;
  final CancelMyTripUseCase cancelMyTrip;
  final OfferPriceUseCase offerPrice;
  final GetMyTripsForPassengerUseCase getMyTrips;

  HomePassengerBloc({
    required this.offerPrice,
    required this.cancelMyTrip,
    required this.getUser,
    required this.getBookings,
    required this.getTrips,
    required this.cancelBooking,
    required this.createBooking,
    required this.getMyTrips,
  }) : super(HomePassengerInitial()) {
    on<HomePassengerInit>(_onInit);
    on<HomePassengerSilentRefresh>(_onSilentRefresh);
    on<LoadMoreActiveTrips>(_onLoadMoreTrips);

    on<CancelBookingPressed>(_onCancel);
    on<CreateBookingRequested>(_onCreateBooking);
    on<OfferPriceRequested>(_onOffer);
    on<CancelMyTripPressed>(_onCancelMyTrip);

    on<MyTripsTabOpened>(_onMyTripsTabOpened);
    on<RefreshMyTripsPressed>(_onRefreshMyTrips);
  }

  bool _silentRefreshing = false;

  bool _isUnauth(dynamic error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('unauthenticated') || msg.contains('401');
  }

  // Qaysi tab aktiv ekanini bloc saqlamaydi — screen'dan event orqali kelar
  // Tab0 → inProgress, Tab1 → myTrips
  // Shuning uchun _currentTab ni screen boshqaradi, biz faqat eventga qaraymiz.

  Future<void> _onInit(
      HomePassengerInit event,
      Emitter<HomePassengerState> emit,
      ) async {
    emit(HomePassengerLoading());

    try {
      // Init da faqat: user + in_progress + active (3 ta)
      // my trips — faqat tab1 ochilganda yuklanadi
      final results = await Future.wait([
        getUser(),
        getBookings(),
        getTrips(page: 1, perPage: 10),
      ]);

      final tripsPage = results[2] as TripsPage;

      emit(
        HomePassengerLoaded(
          user: results[0] as UserModel,
          inProgress: results[1] as List<BookingModel>,
          trips: tripsPage.items,
          tripsNextPage: tripsPage.nextPage,
          tripsHasMore: tripsPage.hasMore,
          isTripsLoadingMore: false,
          myTrips: const [],
          myTripsLoadedOnce: false,
        ),
      );
    } catch (e, s) {
      emit(
        _isUnauth(e)
            ? HomePassengerUnauthorized()
            : HomePassengerError(e.toString()),
      );
    }
  }

  Future<void> _onSilentRefresh(
      HomePassengerSilentRefresh e,
      Emitter<HomePassengerState> emit,
      ) async {
    final s = state;
    if (s is! HomePassengerLoaded) return;
    if (_silentRefreshing) return;
    _silentRefreshing = true;

    try {
      if (e.isTab1) {
        // Tab1 (Buyurtmalarim): user + my + active
        final results = await Future.wait([
          getUser(),
          getMyTrips(),
          getTrips(page: 1, perPage: 10),
        ]);

        final freshUser = results[0] as UserModel;
        final freshMyTrips = (results[1] as MyTripsResponse).items;
        final freshTripsPage = results[2] as TripsPage;

        emit(s.copyWith(
          user: freshUser,
          myTrips: freshMyTrips,
          myTripsLoadedOnce: true,
          trips: freshTripsPage.items,
          tripsNextPage: freshTripsPage.nextPage,
          tripsHasMore: freshTripsPage.hasMore,
          isTripsLoadingMore: false,
          cancelMessage: s.cancelMessage,
          cancelError: s.cancelError,
          createMessage: s.createMessage,
          createError: s.createError,
          offerMessage: s.offerMessage,
          offerError: s.offerError,
          tripCancelMessage: s.tripCancelMessage,
          tripCancelError: s.tripCancelError,
          myTripsError: s.myTripsError,
        ));
      } else {
        // Tab0 (Bronlarim): user + in_progress + active
        final results = await Future.wait([
          getUser(),
          getBookings(),
          getTrips(page: 1, perPage: 10),
        ]);

        final freshUser = results[0] as UserModel;
        final freshBookings = results[1] as List<BookingModel>;
        final freshTripsPage = results[2] as TripsPage;

        emit(s.copyWith(
          user: freshUser,
          inProgress: freshBookings,
          trips: freshTripsPage.items,
          tripsNextPage: freshTripsPage.nextPage,
          tripsHasMore: freshTripsPage.hasMore,
          isTripsLoadingMore: false,
          cancelMessage: s.cancelMessage,
          cancelError: s.cancelError,
          createMessage: s.createMessage,
          createError: s.createError,
          offerMessage: s.offerMessage,
          offerError: s.offerError,
          tripCancelMessage: s.tripCancelMessage,
          tripCancelError: s.tripCancelError,
          myTripsError: s.myTripsError,
        ));
      }
    } catch (err) {
      if (_isUnauth(err)) emit(HomePassengerUnauthorized());
    } finally {
      _silentRefreshing = false;
    }
  }

  Future<void> _onLoadMoreTrips(
      LoadMoreActiveTrips event,
      Emitter<HomePassengerState> emit,
      ) async {
    final current = state;
    if (current is! HomePassengerLoaded) return;

    if (!current.tripsHasMore || current.isTripsLoadingMore) return;

    emit(current.copyWith(isTripsLoadingMore: true));

    try {
      final pageRes = await getTrips(page: current.tripsNextPage, perPage: 10);

      final existingIds = current.trips.map((e) => e.id).toSet();
      final newItems = pageRes.items
          .where((e) => !existingIds.contains(e.id))
          .toList();

      emit(
        current.copyWith(
          trips: [...current.trips, ...newItems],
          tripsNextPage: pageRes.nextPage,
          tripsHasMore: pageRes.hasMore,
          isTripsLoadingMore: false,
        ),
      );
    } catch (e) {
      if (_isUnauth(e)) {
        emit(HomePassengerUnauthorized());
      } else {
        emit(current.copyWith(isTripsLoadingMore: false));
      }
    }
  }

  List<T> _mergeKeepOrderAndAppendNew<T>({
    required List<T> oldList,
    required List<T> freshList,
    required int Function(T) idOf,
    bool Function(T old, T fresh)? shouldUpdate, // ixtiyoriy
  }) {
    final freshMap = <int, T>{for (final x in freshList) idOf(x): x};
    final used = <int>{};
    final result = <T>[];

    for (final old in oldList) {
      final id = idOf(old);
      final fresh = freshMap[id];
      if (fresh != null) {
        // Fresh ma' to'liq ishlatamiz
        result.add(fresh);
      } else {
        result.add(old);
      }
      used.add(id);
    }

    for (final fresh in freshList) {
      final id = idOf(fresh);
      if (!used.contains(id)) {
        result.add(fresh);
      }
    }

    return result;
  }

  Future<void> _onCancelMyTrip(
      CancelMyTripPressed event,
      Emitter<HomePassengerState> emit,
      ) async {
    final current = state;
    if (current is! HomePassengerLoaded) return;

    emit(
      current.copyWith(
        isTripCancelLoading: true,
        tripCancelMessage: null,
        tripCancelError: null,
      ),
    );

    try {
      final msg = await cancelMyTrip(tripId: event.tripId);

      List<MyTripItem> myTrips = current.myTrips;
      if (current.myTripsLoadedOnce) {
        try {
          myTrips = (await getMyTrips()).items;
        } catch (_) {}
      } else {
        myTrips = current.myTrips.where((x) => x.id != event.tripId).toList();
      }

      final refreshed = await Future.wait([
        getUser(),
        getBookings(),
        getTrips(page: 1, perPage: 10),
      ]);

      final tripsPage = refreshed[2] as TripsPage;

      emit(
        current.copyWith(
          user: refreshed[0] as UserModel,
          inProgress: refreshed[1] as List<BookingModel>,
          trips: tripsPage.items,
          tripsNextPage: tripsPage.nextPage,
          tripsHasMore: tripsPage.hasMore,
          isTripsLoadingMore: false,

          myTrips: myTrips,
          isMyTripsLoading: false,
          isTripCancelLoading: false,
          tripCancelMessage: msg,
        ),
      );
    } catch (e, s) {
      if (_isUnauth(e)) {
        emit(HomePassengerUnauthorized());
      } else {
        emit(
          current.copyWith(
            isTripCancelLoading: false,
            isMyTripsLoading: false,
            tripCancelError: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _onMyTripsTabOpened(
      MyTripsTabOpened event,
      Emitter<HomePassengerState> emit,
      ) async {
    final current = state;
    if (current is! HomePassengerLoaded) return;

    if (current.myTripsLoadedOnce || current.isMyTripsLoading) return;

    emit(current.copyWith(isMyTripsLoading: true, myTripsError: null));

    try {
      final res = await getMyTrips();
      emit(
        current.copyWith(
          myTrips: res.items,
          isMyTripsLoading: false,
          myTripsLoadedOnce: true,
        ),
      );
    } catch (e) {
      if (_isUnauth(e)) {
        emit(HomePassengerUnauthorized());
      } else {
        emit(
          current.copyWith(isMyTripsLoading: false, myTripsError: e.toString()),
        );
      }
    }
  }

  Future<void> _onRefreshMyTrips(
      RefreshMyTripsPressed event,
      Emitter<HomePassengerState> emit,
      ) async {
    final current = state;
    if (current is! HomePassengerLoaded) return;
    if (current.isMyTripsLoading || current.isTripCancelLoading) return;

    emit(current.copyWith(isMyTripsLoading: true, myTripsError: null));

    try {
      // Tab1 full refresh: user + my + active (3 ta)
      final results = await Future.wait([
        getUser(),
        getMyTrips(),
        getTrips(page: 1, perPage: 10),
      ]);

      final freshState = state;
      if (freshState is! HomePassengerLoaded) return;

      final freshUser = results[0] as UserModel;
      final freshMyTrips = (results[1] as MyTripsResponse).items;
      final freshTripsPage = results[2] as TripsPage;

      emit(freshState.copyWith(
        user: freshUser,
        myTrips: freshMyTrips,
        isMyTripsLoading: false,
        myTripsLoadedOnce: true,
        trips: freshTripsPage.items,
        tripsNextPage: freshTripsPage.nextPage,
        tripsHasMore: freshTripsPage.hasMore,
        isTripsLoadingMore: false,
      ));
    } catch (e, s) {
      if (_isUnauth(e)) {
        emit(HomePassengerUnauthorized());
      } else {
        final cur = state;
        if (cur is HomePassengerLoaded) {
          emit(cur.copyWith(
            isMyTripsLoading: false,
            myTripsError: e.toString(),
          ));
        }
      }
    }
  }

  Future<void> _onOffer(
      OfferPriceRequested event,
      Emitter<HomePassengerState> emit,
      ) async {
    final current = state;
    if (current is! HomePassengerLoaded) return;

    emit(
      current.copyWith(
        isOfferLoading: true,
        offerMessage: null,
        offerError: null,
      ),
    );

    try {
      final msg = await offerPrice(
        tripId: event.tripId,
        seats: event.seats,
        offeredPrice: event.offeredPrice,
        comment: event.comment,
      );

      final refreshed = await Future.wait([
        getUser(),
        getBookings(),
        getTrips(page: 1, perPage: 10),
      ]);

      final tripsPage = refreshed[2] as TripsPage;

      List<MyTripItem> myTrips = current.myTrips;
      if (current.myTripsLoadedOnce) {
        try {
          myTrips = (await getMyTrips()).items;
        } catch (_) {}
      }

      emit(
        current.copyWith(
          user: refreshed[0] as UserModel,
          inProgress: refreshed[1] as List<BookingModel>,
          trips: tripsPage.items,
          tripsNextPage: tripsPage.nextPage,
          tripsHasMore: tripsPage.hasMore,
          isTripsLoadingMore: false,

          myTrips: myTrips,
          isOfferLoading: false,
          offerMessage: msg,
        ),
      );
    } catch (e, s) {
      if (_isUnauth(e)) {
        emit(HomePassengerUnauthorized());
      } else {
        emit(current.copyWith(isOfferLoading: false, offerError: e.toString()));
      }
    }
  }

  Future<void> _onCreateBooking(
      CreateBookingRequested event,
      Emitter<HomePassengerState> emit,
      ) async {
    final current = state;
    if (current is! HomePassengerLoaded) return;

    emit(
      current.copyWith(
        isCreateLoading: true,
        createMessage: null,
        createError: null,
      ),
    );

    try {
      final msg = await createBooking(tripId: event.tripId, seats: event.seats);

      final refreshed = await Future.wait([
        getUser(),
        getBookings(),
        getTrips(page: 1, perPage: 10),
      ]);

      final tripsPage = refreshed[2] as TripsPage;

      List<MyTripItem> myTrips = current.myTrips;
      if (current.myTripsLoadedOnce) {
        try {
          myTrips = (await getMyTrips()).items;
        } catch (_) {}
      }

      emit(
        current.copyWith(
          user: refreshed[0] as UserModel,
          inProgress: refreshed[1] as List<BookingModel>,
          trips: tripsPage.items,
          tripsNextPage: tripsPage.nextPage,
          tripsHasMore: tripsPage.hasMore,
          isTripsLoadingMore: false,

          myTrips: myTrips,
          isCreateLoading: false,
          createMessage: msg,
        ),
      );
    } catch (e) {
      if (_isUnauth(e)) {
        emit(HomePassengerUnauthorized());
      } else {
        emit(
          current.copyWith(isCreateLoading: false, createError: e.toString()),
        );
      }
    }
  }

  Future<void> _onCancel(
      CancelBookingPressed event,
      Emitter<HomePassengerState> emit,
      ) async {
    final current = state;
    if (current is! HomePassengerLoaded) return;

    emit(
      current.copyWith(
        isCancelLoading: true,
        cancelMessage: null,
        cancelError: null,
      ),
    );

    try {
      final msg = await cancelBooking(bookingId: event.bookingId);

      final refreshed = await Future.wait([
        getUser(),
        getBookings(),
        getTrips(page: 1, perPage: 10),
      ]);

      final tripsPage = refreshed[2] as TripsPage;

      List<MyTripItem> myTrips = current.myTrips;
      if (current.myTripsLoadedOnce) {
        try {
          myTrips = (await getMyTrips()).items;
        } catch (_) {}
      }

      emit(
        current.copyWith(
          user: refreshed[0] as UserModel,
          inProgress: refreshed[1] as List<BookingModel>,
          trips: tripsPage.items,
          tripsNextPage: tripsPage.nextPage,
          tripsHasMore: tripsPage.hasMore,
          isTripsLoadingMore: false,

          myTrips: myTrips,
          isCancelLoading: false,
          cancelMessage: msg,
        ),
      );
    } catch (e, s) {
      if (_isUnauth(e)) {
        emit(HomePassengerUnauthorized());
      } else {
        emit(
          current.copyWith(isCancelLoading: false, cancelError: e.toString()),
        );
      }
    }
  }
}