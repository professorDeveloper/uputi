part of 'history_bloc.dart';

@immutable
sealed class HistoryEvent {}

final class HistoryFetchFirst extends HistoryEvent {
  final int type; 
  HistoryFetchFirst({required this.type});
}

final class HistoryLoadMore extends HistoryEvent {
  HistoryLoadMore();
}

final class HistoryRefresh extends HistoryEvent {
  HistoryRefresh();
}

final class HistoryChangeType extends HistoryEvent {
  final int type; // 1/2
  HistoryChangeType({required this.type});
}
