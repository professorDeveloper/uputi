import 'package:flutter/material.dart';

enum TripCreateStatus { idle, submitting, success, failure }

class TripCreateState {
  final DateTime date;
  final TimeOfDay time;
  final int seats;      // 1..4 (default 1)
  final int amount;     // >0
  final TripCreateStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? createdTrip;

  const TripCreateState({
    required this.date,
    required this.time,
    required this.seats,
    required this.amount,
    required this.status,
    required this.errorMessage,
    required this.createdTrip,
  });

  factory TripCreateState.initial() {
    final now = DateTime.now();
    return TripCreateState(
      date: DateTime(now.year, now.month, now.day),
      time: TimeOfDay.now(),
      seats: 1,
      amount: 0,
      status: TripCreateStatus.idle,
      errorMessage: null,
      createdTrip: null,
    );
  }

  bool get canSubmit {
    return amount > 0 &&
        seats >= 1 &&
        seats <= 4 &&
        status != TripCreateStatus.submitting;
  }

  TripCreateState copyWith({
    DateTime? date,
    TimeOfDay? time,
    int? seats,
    int? amount,
    TripCreateStatus? status,
    String? errorMessage,
    Map<String, dynamic>? createdTrip,
  }) {
    return TripCreateState(
      date: date ?? this.date,
      time: time ?? this.time,
      seats: seats ?? this.seats,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      errorMessage: errorMessage,
      createdTrip: createdTrip ?? this.createdTrip,
    );
  }
}
