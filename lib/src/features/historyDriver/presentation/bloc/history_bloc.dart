import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:uputi/src/features/historyDriver/presentation/bloc/history_state.dart';

import '../../data/models/driver_history_resposne.dart';
import '../../domain/usecase/get_driver_history_usecase.dart';
import 'history_event.dart';

class DriverHistoryBloc extends Bloc<DriverHistoryEvent, DriverHistoryState> {
  final GetDriverHistoryUseCase getHistory;

  DriverHistoryBloc({required this.getHistory})
    : super(const DriverHistoryInitial(type: 1)) {
    on<DriverHistoryFetchFirst>(_onFetchFirst);
    on<DriverHistoryLoadMore>(_onLoadMore);
    on<DriverHistoryRefresh>(_onRefresh);
    on<DriverHistoryChangeType>(_onChangeType);
  }

  Future<void> _onFetchFirst(
    DriverHistoryFetchFirst event,
    Emitter<DriverHistoryState> emit,
  ) async {
    emit(DriverHistoryLoading(type: event.type));

    try {
      final res = await getHistory(
        GetDriverHistoryParams(type: event.type, page: 1),
      );

      final tripsPage = res.trips;
      final List<Trip> items = List<Trip>.from(tripsPage.data);
      debugPrint('Fetched ${items.length} items for type ${event.type}');
      emit(
        DriverHistoryLoaded(
          type: event.type,
          items: items,
          currentPage: tripsPage.currentPage,
          lastPage: tripsPage.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(DriverHistoryFailure(type: event.type, message: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    DriverHistoryLoadMore event,
    Emitter<DriverHistoryState> emit,
  ) async {
    final state = this.state;
    if (state is! DriverHistoryLoaded) return;

    if (state.isLoadingMore) return;
    if (!state.hasNext) return;

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingMore: true));

    try {
      final res = await getHistory(
        GetDriverHistoryParams(type: state.type, page: nextPage),
      );
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
      debugPrint('Failed to load more: $e');
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefresh(
    DriverHistoryRefresh event,
    Emitter<DriverHistoryState> emit,
  ) async {
    final currentType = switch (state) {
      DriverHistoryInitial s => s.type,
      DriverHistoryLoading s => s.type,
      DriverHistoryLoaded s => s.type,
      DriverHistoryFailure s => s.type,
      _ => 1,
    };

    add(DriverHistoryFetchFirst(type: currentType));
  }

  Future<void> _onChangeType(
    DriverHistoryChangeType event,
    Emitter<DriverHistoryState> emit,
  ) async {
    add(DriverHistoryFetchFirst(type: event.type));
  }
}
