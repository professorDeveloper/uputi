// lib/src/features/searchDriver/presentation/blocs/driver_city_search_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../searchPassenger/data/models/search_city_trip_response.dart';
import '../../domain/usecases/search_driver_by_location_usecase.dart';

part 'driver_city_search_event.dart';
part 'driver_city_search_state.dart';

class DriverCitySearchBloc
    extends Bloc<DriverCitySearchEvent, DriverCitySearchState> {
  final SearchDriverByLocationUseCase searchByLocation;

  DriverCitySearchBloc({required this.searchByLocation})
      : super(DriverCitySearchInitial()) {
    on<DriverCitySearchRequested>(_onSearch);
    on<DriverCitySearchRefreshed>(_onRefresh);
    on<DriverCitySearchCleared>(_onClear);
  }

  Future<void> _onSearch(
      DriverCitySearchRequested event,
      Emitter<DriverCitySearchState> emit,
      ) async {
    emit(DriverCitySearchLoading());

    try {
      final res = await searchByLocation(
        latitude: event.lat,
        longitude: event.lng,
      );
      emit(DriverCitySearchLoaded(
        response: res,
        lastLat: event.lat,
        lastLng: event.lng,
      ));
    } catch (e) {
      emit(DriverCitySearchError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
      DriverCitySearchRefreshed event,
      Emitter<DriverCitySearchState> emit,
      ) async {
    final st = state;
    if (st is! DriverCitySearchLoaded) return;

    emit(st.copyWith(isRefreshing: true, errorMessage: null));

    try {
      final res = await searchByLocation(
        latitude: st.lastLat,
        longitude: st.lastLng,
      );
      emit(st.copyWith(
        isRefreshing: false,
        response: res,
        errorMessage: null,
      ));
    } catch (e) {
      emit(st.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClear(
      DriverCitySearchCleared event,
      Emitter<DriverCitySearchState> emit,
      ) {
    emit(DriverCitySearchInitial());
  }
}