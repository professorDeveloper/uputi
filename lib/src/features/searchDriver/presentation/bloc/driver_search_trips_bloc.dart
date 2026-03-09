// lib/src/features/searchDriver/presentation/blocs/driver_search_trips_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../homeDriver/domain/usecase/create_booking_usecase.dart';
import '../../data/entities/search_driver_region_response.dart';
import '../../domain/usecases/search_driver_usecase.dart';

part 'driver_search_trips_event.dart';

part 'driver_search_trips_state.dart';

class DriverSearchTripsBloc
    extends Bloc<DriverSearchTripsEvent, DriverSearchTripsState> {
  final SearchDriverPassengersUseCase searchPassengers;
  final CreateDriverBookingUseCase createBooking;

  String? _lastFrom;
  String? _lastTo;
  String? _lastDate;

  DriverSearchTripsBloc({
    required this.searchPassengers,
    required this.createBooking,
  }) : super(
    DriverSearchTripsLoaded(response: SearchDriverRegionResponse.empty()),
  ) {
    on<DriverSearchTripsRequested>(_onSearch);
    on<DriverSearchTripsLoadMoreRequested>(_onLoadMore);
    on<DriverSearchCreateBookingRequested>(_onCreateBooking);
  }

  DriverSearchTripsLoaded _loadedOrEmpty() {
    final st = state;
    if (st is DriverSearchTripsLoaded) return st;
    return DriverSearchTripsLoaded(
      response: SearchDriverRegionResponse.empty(),
    );
  }

  Future<void> _onSearch(
      DriverSearchTripsRequested event,
      Emitter<DriverSearchTripsState> emit,
      ) async {
    _lastFrom = event.from;
    _lastTo = event.to;
    _lastDate = event.date;

    emit(DriverSearchTripsLoading());
    try {
      final res = await searchPassengers(
        from: event.from,
        to: event.to,
        date: event.date,
      );
      emit(DriverSearchTripsLoaded(response: res));
    } catch (e) {
      emit(DriverSearchTripsError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      DriverSearchTripsLoadMoreRequested event,
      Emitter<DriverSearchTripsState> emit,
      ) async {
    final cur = state;
    if (cur is! DriverSearchTripsLoaded) return;
    if (cur.paginationLoading) return;

    final pagination = cur.response.pagination;
    if (!pagination.hasNextPage) return;
    final nextPage = pagination.nextPage;
    if (nextPage == null) return;
    if (_lastFrom == null || _lastTo == null) return;

    emit(cur.copyWith(paginationLoading: true));

    try {
      final res = await searchPassengers(
        from: _lastFrom!,
        to: _lastTo!,
        date: _lastDate,
        page: nextPage,
      );

      final merged = SearchDriverRegionResponse(
        items: [...cur.response.items, ...res.items],
        pagination: res.pagination,
      );

      emit(cur.copyWith(response: merged, paginationLoading: false));
    } catch (e) {
      emit(cur.copyWith(paginationLoading: false, actionError: e.toString()));
    }
  }

  Future<void> _onCreateBooking(
      DriverSearchCreateBookingRequested event,
      Emitter<DriverSearchTripsState> emit,
      ) async {
    if (state is DriverSearchTripsLoading) return;

    final base = _loadedOrEmpty();

    emit(
      base.copyWith(
        actionLoading: true,
        actionMessage: null,
        actionError: null,
      ),
    );

    try {
      await createBooking(tripId: event.tripId);
      final cur = _loadedOrEmpty();
      emit(
        cur.copyWith(
          actionLoading: false,
          actionMessage: "Bron yuborildi",
          actionError: null,
        ),
      );
    } catch (e) {
      final cur = _loadedOrEmpty();
      emit(
        cur.copyWith(
          actionLoading: false,
          actionMessage: null,
          actionError: e.toString(),
        ),
      );
    }
  }
}