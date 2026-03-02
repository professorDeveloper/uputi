import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../data/models/passenger_history_response.dart'; // <-- sizdagi pathga moslang
import '../../domain/usecases/get_passenger_history_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetPassengerHistoryUseCase getHistory;

  HistoryBloc({required this.getHistory}) : super(const HistoryInitial(type: 1)) {
    on<HistoryFetchFirst>(_onFetchFirst);
    on<HistoryLoadMore>(_onLoadMore);
    on<HistoryRefresh>(_onRefresh);
    on<HistoryChangeType>(_onChangeType);
  }

  Future<void> _onFetchFirst(HistoryFetchFirst event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading(type: event.type));

    try {
      final res = await getHistory(GetPassengerHistoryParams(type: event.type, page: 1));

      final tripsPage = res.trips;
      final List<Trip> items = List<Trip>.from(tripsPage.data);
      debugPrint('Fetched ${items.length} items for type ${event.type}');
      emit(
        HistoryLoaded(
          type: event.type,
          items: items,
          currentPage: tripsPage.currentPage,
          lastPage: tripsPage.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(HistoryFailure(type: event.type, message: e.toString()));
    }
  }

  Future<void> _onLoadMore(HistoryLoadMore event, Emitter<HistoryState> emit) async {
    final state = this.state;
    if (state is! HistoryLoaded) return;

    if (state.isLoadingMore) return;
    if (!state.hasNext) return;

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingMore: true));

    try {
      final res = await getHistory(GetPassengerHistoryParams(type: state.type, page: nextPage));
      final tripsPage = res.trips;

      final List<Trip> newItems = List<Trip>.from(tripsPage.data);

      emit(
        state.copyWith(
          items: [...state.items, ...newItems],
          currentPage: tripsPage.currentPage,
          lastPage: tripsPage.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefresh(HistoryRefresh event, Emitter<HistoryState> emit) async {
    final currentType = switch (state) {
      HistoryInitial s => s.type,
      HistoryLoading s => s.type,
      HistoryLoaded s => s.type,
      HistoryFailure s => s.type,
      _ => 1,
    };

    add(HistoryFetchFirst(type: currentType));
  }

  Future<void> _onChangeType(HistoryChangeType event, Emitter<HistoryState> emit) async {
    add(HistoryFetchFirst(type: event.type));
  }
}
