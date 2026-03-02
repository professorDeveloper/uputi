import 'package:flutter/material.dart';

enum DriverTripCreateStatus { idle, submitting, success, failure }

class DriverTripCreateState {
  final DateTime date;
  final TimeOfDay time;
  final int seats;      // 1..4 (default 1)
  final int amount;     // >0
  final String comment; // ixtiyoriy izoh
  final DriverTripCreateStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? createdTrip;

  const DriverTripCreateState({
    required this.date,
    required this.time,
    required this.seats,
    required this.amount,
    required this.comment,
    required this.status,
    required this.errorMessage,
    required this.createdTrip,
  });

  factory DriverTripCreateState.initial() {
    final now = DateTime.now();
    return DriverTripCreateState(
      date: DateTime(now.year, now.month, now.day),
      time: TimeOfDay.now(),
      seats: 1,
      amount: 0,
      comment: '',
      status: DriverTripCreateStatus.idle,
      errorMessage: null,
      createdTrip: null,
    );
  }

  bool get canSubmit =>
      amount > 0 &&
          seats >= 1 &&
          seats <= 4 &&
          status != DriverTripCreateStatus.submitting;

  DriverTripCreateState copyWith({
    DateTime? date,
    TimeOfDay? time,
    int? seats,
    int? amount,
    String? comment,
    DriverTripCreateStatus? status,
    String? errorMessage,
    Map<String, dynamic>? createdTrip,
  }) {
    return DriverTripCreateState(
      date: date ?? this.date,
      time: time ?? this.time,
      seats: seats ?? this.seats,
      amount: amount ?? this.amount,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      errorMessage: errorMessage,
      createdTrip: createdTrip ?? this.createdTrip,
    );
  }
}