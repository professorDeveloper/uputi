import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uputi/src/features/searchPassenger/data/models/search_region_trip_response.dart';
import 'package:uputi/src/features/searchPassenger/domain/usecases/search_passenger_usecase.dart';

import '../../../homePassenger/domain/usecases/create_booking_use_case.dart';
import '../../../homePassenger/domain/usecases/offer_price_use_case.dart';

part 'search_trips_event.dart';
part 'search_trips_state.dart';

class SearchTripsBloc extends Bloc<SearchTripsEvent, SearchTripsState> {
  final SearchPassengerUseCase searchTrips;
  final CreateBookingUseCase createBooking;
  final OfferPriceUseCase offerPrice;

  // Keep last search params to reuse for load-more
  String? _lastFrom;
  String? _lastTo;
  String? _lastDate;

  SearchTripsBloc({
    required this.searchTrips,
    required this.createBooking,
    required this.offerPrice,
  }) : super(
    SearchTripsLoaded(
      response: SearchRegionTripResponse.empty(),
      actionLoading: false,
      actionMessage: null,
      actionError: null,
    ),
  ) {
    on<SearchTripsRequested>(_onSearch);
    on<SearchTripsLoadMoreRequested>(_onLoadMore);
    on<SearchTripsCreateBookingRequested>(_onCreateBooking);
    on<SearchTripsOfferPriceRequested>(_onOfferPrice);
  }

  SearchTripsLoaded _loadedOrEmpty() {
    final st = state;
    if (st is SearchTripsLoaded) return st;
    return SearchTripsLoaded(
      response: SearchRegionTripResponse.empty(),
      actionLoading: false,
      actionMessage: null,
      actionError: null,
    );
  }

  Future<void> _onSearch(
      SearchTripsRequested event,
      Emitter<SearchTripsState> emit,
      ) async {
    _lastFrom = event.from;
    _lastTo = event.to;
    _lastDate = event.date;

    emit(SearchTripsLoading());
    try {
      final res = await searchTrips(
        from: event.from,
        to: event.to,
        date: event.date,
      );
      emit(SearchTripsLoaded(response: res));
    } catch (e) {
      emit(SearchTripsError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      SearchTripsLoadMoreRequested event,
      Emitter<SearchTripsState> emit,
      ) async {
    final cur = state;
    if (cur is! SearchTripsLoaded) return;
    if (cur.paginationLoading) return;

    final pagination = cur.response.pagination;
    if (!pagination.hasNextPage) return;
    final nextPage = pagination.nextPage;
    if (nextPage == null) return;

    if (_lastFrom == null || _lastTo == null) return;

    emit(cur.copyWith(paginationLoading: true));

    try {
      final res = await searchTrips(
        from: _lastFrom!,
        to: _lastTo!,
        date: _lastDate,
        page: nextPage,
      );

      // Merge new items with existing
      final merged = SearchRegionTripResponse(
        items: [...cur.response.items, ...res.items],
        pagination: res.pagination,
      );

      emit(cur.copyWith(response: merged, paginationLoading: false));
    } catch (e) {
      emit(cur.copyWith(paginationLoading: false, actionError: e.toString()));
    }
  }

  Future<void> _onCreateBooking(
      SearchTripsCreateBookingRequested event,
      Emitter<SearchTripsState> emit,
      ) async {
    if (state is SearchTripsLoading) return;

    final base = _loadedOrEmpty();

    emit(base.copyWith(actionLoading: true, actionMessage: null, actionError: null));
    try {
      await createBooking(tripId: event.tripId, seats: event.seats);
      final cur = _loadedOrEmpty();
      emit(cur.copyWith(actionLoading: false, actionMessage: "Bron yuborildi", actionError: null));
    } catch (e) {
      final cur = _loadedOrEmpty();
      emit(cur.copyWith(actionLoading: false, actionMessage: null, actionError: e.toString()));
    }
  }

  Future<void> _onOfferPrice(
      SearchTripsOfferPriceRequested event,
      Emitter<SearchTripsState> emit,
      ) async {
    if (state is SearchTripsLoading) return;

    final base = _loadedOrEmpty();

    emit(base.copyWith(actionLoading: true, actionMessage: null, actionError: null));
    try {
      await offerPrice(
        tripId: event.tripId,
        seats: event.seats,
        offeredPrice: event.offeredPrice,
        comment: event.comment,
      );
      final cur = _loadedOrEmpty();
      emit(cur.copyWith(actionLoading: false, actionMessage: "Taklif yuborildi", actionError: null));
    } catch (e) {
      final cur = _loadedOrEmpty();
      emit(cur.copyWith(actionLoading: false, actionMessage: null, actionError: e.toString()));
    }
  }
}