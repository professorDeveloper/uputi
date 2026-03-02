// city_search_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../domain/usecases/search_trips_by_location_usecase.dart';
import '../../data/models/search_city_trip_response.dart';

part 'city_search_event.dart';
part 'city_search_state.dart';

class CitySearchBloc extends Bloc<CitySearchEvent, CitySearchState> {
  final SearchTripsByLocationUsecase searchByLocation;

  CitySearchBloc({required this.searchByLocation}) : super(CitySearchInitial()) {
    on<CitySearchRequested>(_onSearch);
    on<CitySearchRefreshed>(_onRefresh);
    on<CitySearchCleared>(_onClear);
  }

  Future<void> _onSearch(
      CitySearchRequested event,
      Emitter<CitySearchState> emit,
      ) async {
    emit(CitySearchLoading());

    try {
      final res = await searchByLocation(
        latitude: event.lat,
        longitude: event.lng,
      );

      emit(CitySearchLoaded(
        response: res,
        lastLat: event.lat,
        lastLng: event.lng,
      ));
    } catch (e) {
      emit(CitySearchError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
      CitySearchRefreshed event,
      Emitter<CitySearchState> emit,
      ) async {
    final st = state;
    if (st is! CitySearchLoaded) return;

    emit(st.copyWith(isRefreshing: true, errorMessage: null));

    try {
      final res = await searchByLocation(latitude: st.lastLat, longitude: st.lastLng);
      emit(st.copyWith(isRefreshing: false, response: res, errorMessage: null));
    } catch (e) {
      emit(st.copyWith(isRefreshing: false, errorMessage: e.toString()));
    }
  }

  void _onClear(CitySearchCleared event, Emitter<CitySearchState> emit) {
    emit(CitySearchInitial());
  }
}
