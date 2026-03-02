part of 'history_bloc.dart';

@immutable
sealed class HistoryState {
  final int type;
  const HistoryState({required this.type});
}

final class HistoryInitial extends HistoryState {
  const HistoryInitial({required super.type});
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading({required super.type});
}

final class HistoryFailure extends HistoryState {
  final String message;
  const HistoryFailure({required super.type, required this.message});
}

final class HistoryLoaded extends HistoryState {
  final List<Trip> items;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  const HistoryLoaded({
    required super.type,
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.isLoadingMore,
  });

  bool get hasNext => currentPage < lastPage;

  HistoryLoaded copyWith({
    List<Trip>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return HistoryLoaded(
      type: type,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
