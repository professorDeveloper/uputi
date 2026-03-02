
sealed class DriverHistoryEvent {}

final class DriverHistoryFetchFirst extends DriverHistoryEvent {
  final int type;
  DriverHistoryFetchFirst({required this.type});
}

final class DriverHistoryLoadMore extends DriverHistoryEvent {
  DriverHistoryLoadMore();
}

final class DriverHistoryRefresh extends DriverHistoryEvent {
  DriverHistoryRefresh();
}

final class DriverHistoryChangeType extends DriverHistoryEvent {
  final int type; // 1/2
  DriverHistoryChangeType({required this.type});
}