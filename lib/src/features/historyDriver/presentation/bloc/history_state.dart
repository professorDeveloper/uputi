
import 'package:flutter/cupertino.dart';

import '../../data/models/driver_history_resposne.dart';

@immutable
sealed class DriverHistoryState {
  final int type;
  const DriverHistoryState({required this.type});
}

final class DriverHistoryInitial extends DriverHistoryState {
  const DriverHistoryInitial({required super.type});
}

final class DriverHistoryLoading extends DriverHistoryState {
  const DriverHistoryLoading({required super.type});
}

final class DriverHistoryFailure extends DriverHistoryState {
  final String message;
  const DriverHistoryFailure({required super.type, required this.message});
}

final class DriverHistoryLoaded extends DriverHistoryState {
  final List<Trip> items;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  const DriverHistoryLoaded({
    required super.type,
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.isLoadingMore,
  });

  bool get hasNext => currentPage < lastPage;

  DriverHistoryLoaded copyWith({
    List<Trip>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return DriverHistoryLoaded(
      type: type,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}