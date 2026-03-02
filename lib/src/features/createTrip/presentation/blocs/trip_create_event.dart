import 'package:flutter/material.dart';

sealed class TripCreateEvent {}

class TripCreateReset extends TripCreateEvent {}

class TripCreateDateChanged extends TripCreateEvent {
  final DateTime date;
  TripCreateDateChanged(this.date);
}

class TripCreateTimeChanged extends TripCreateEvent {
  final TimeOfDay time;
  TripCreateTimeChanged(this.time);
}

class TripCreateSeatsChanged extends TripCreateEvent {
  final int seats; // 1..4
  TripCreateSeatsChanged(this.seats);
}

class TripCreateAmountChanged extends TripCreateEvent {
  final int amount; // UZS
  TripCreateAmountChanged(this.amount);
}

class TripCreateSubmitted extends TripCreateEvent {
  final double fromLat;
  final double fromLng;
  final String fromAddress;

  final double toLat;
  final double toLng;
  final String toAddress;

  TripCreateSubmitted({
    required this.fromLat,
    required this.fromLng,
    required this.fromAddress,
    required this.toLat,
    required this.toLng,
    required this.toAddress,
  });
}
