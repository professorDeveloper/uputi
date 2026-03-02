import 'package:flutter/material.dart';

sealed class DriverTripCreateEvent {}

class DriverTripCreateReset extends DriverTripCreateEvent {}

class DriverTripCreateDateChanged extends DriverTripCreateEvent {
  final DateTime date;

  DriverTripCreateDateChanged(this.date);
}

class DriverTripCreateTimeChanged extends DriverTripCreateEvent {
  final TimeOfDay time;

  DriverTripCreateTimeChanged(this.time);
}

class DriverTripCreateSeatsChanged extends DriverTripCreateEvent {
  final int seats; // 1..4
  DriverTripCreateSeatsChanged(this.seats);
}

class DriverTripCreateAmountChanged extends DriverTripCreateEvent {
  final int amount; // UZS
  DriverTripCreateAmountChanged(this.amount);
}

class DriverTripCreateCommentChanged extends DriverTripCreateEvent {
  final String comment;

  DriverTripCreateCommentChanged(this.comment);
}

class DriverTripCreateSubmitted extends DriverTripCreateEvent {
  final double fromLat;
  final double fromLng;
  final String fromAddress;

  final double toLat;
  final double toLng;
  final String toAddress;

  DriverTripCreateSubmitted({
    required this.fromLat,
    required this.fromLng,
    required this.fromAddress,
    required this.toLat,
    required this.toLng,
    required this.toAddress,
  });
}
